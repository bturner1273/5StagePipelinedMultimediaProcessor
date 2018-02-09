
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity alu is 
port(
	opcode: in STD_LOGIC_VECTOR(6 downto 0);  -- 7bit opcode
	rs1_data: in STD_LOGIC_VECTOR(63 downto 0);
	rs2_data: in STD_LOGIC_VECTOR(63 downto 0);
    ------------------------------------------------------------------------
    rs3_data: in STD_LOGIC_VECTOR(63 downto 0);
    ALUcontrol_in: in STD_LOGIC_VECTOR(1 downto 0);
    MAMS_in: in STD_LOGIC_VECTOR(1 downto 0);
    imm_in: in STD_LOGIC_VECTOR(15 downto 0);
    li_location: in STD_LOGIC_VECTOR(1 downto 0);
    rd_data: in STD_LOGIC_VECTOR(63 downto 0);
    ------------------------------------------------------------------------
    
	alu_output: out STD_LOGIC_VECTOR(63 downto 0)
    
	);
end alu;

architecture alu_arch of alu is
	constant nop_logic: std_logic_vector(6 downto 0) := "---0000";
    constant bcw_logic: std_logic_vector (6 downto 0) := "---0001";
    constant and_logic: std_logic_vector(6 downto 0) := "---0010";
	constant or_logic: std_logic_vector(6 downto 0) := "---0011";  
	constant popcnth_logic: std_logic_vector(6 downto 0) := "---0100";
	constant clz_logic: std_logic_vector(6 downto 0) := "---0101";
	constant rot_logic: std_logic_vector(6 downto 0) := "---0110";
	constant shlhi_logic: std_logic_vector(6 downto 0) := "---0111";
    ------------------------------------------------------------------------
    constant a_logic: std_logic_vector(6 downto 0) := "---1000";
    constant sfw_logic: std_logic_vector(6 downto 0) := "---1001";
    constant ah_logic: std_logic_vector(6 downto 0) := "---1010";
    constant sfh_logic: std_logic_vector(6 downto 0) := "---1011";
    constant ahs_logic: std_logic_vector(6 downto 0) := "---1100";
    constant sfhs_logic: std_logic_vector(6 downto 0) := "---1101";
    ------------------------------------------------------------------------
	constant mpyu_logic: std_logic_vector(6 downto 0) := "---1110";
	constant absdb_logic: std_logic_vector(6 downto 0) := "---1111";
    
begin
    process(ALUcontrol_in, MAMS_in, imm_in, li_location, rs3_data, rs2_data, rs1_data, rd_data, opcode)
        --
        variable alu_var: bit_vector(63 downto 0);
        variable alu_vec: std_logic_vector(63 downto 0);
        variable count1:integer;
        variable count2:integer;
        variable count3:integer;
        variable count4:integer; -- operations are done in halfword max
        variable shift_amt:integer;
        variable shlhi_int:integer;
        ---------------------------------------------------------------
        -- MAMS variables ---------------------------------------------
        variable MAMS_result1 : std_logic_vector(31 downto 0);
        variable MAMS_result2 : std_logic_vector(31 downto 0);
        ---------------------------------------------------------------
        -- temps for a, sfw, ah, sfh, ahs sfhs -----------------------------------------------
        variable word_temp0:std_logic_vector(31 downto 0);
        variable word_temp1:std_logic_vector(31 downto 0);
        variable temp0:std_logic_vector(15 downto 0);
        variable temp1:std_logic_vector(15 downto 0);
        variable temp2:std_logic_vector(15 downto 0);
        variable temp3:std_logic_vector(15 downto 0);
        
    begin
        alu_var := to_bitvector(std_logic_vector(to_unsigned(0,64)));
        alu_vec := std_logic_vector(to_unsigned(0,64));
        count1 := 0;
        count2 := 0;
        count3 := 0;
        count4 := 0;
        shift_amt := 0;
        shlhi_int := 0;
        temp0 := std_logic_vector(to_unsigned(0,16));
        temp1 := std_logic_vector(to_unsigned(0,16));
        temp2 := std_logic_vector(to_unsigned(0,16));
        temp3 := std_logic_vector(to_unsigned(0,16));
        MAMS_result1 := std_logic_vector(to_unsigned(0,32));
        MAMS_result2 := std_logic_vector(to_unsigned(0,32));
        word_temp0 := std_logic_vector(to_unsigned(0,32));
        word_temp1 := std_logic_vector(to_unsigned(0,32));
        
        ------------------------------------------------------------------------
        -- li operation
        -- assuming 0 is [15:0], 1 is [31:16], 2 is [47:32], 3 is [63:48]
        ------------------------------------------------------------------------
        if ALUcontrol_in = "10" then
            if li_location = "00" then
                alu_output <= rd_data(63 downto 16) & imm_in;
            elsif li_location = "01" then
                alu_output <= rd_data(63 downto 32) & imm_in & rd_data(15 downto 0);
            elsif li_location = "10" then
                alu_output <= rd_data(63 downto 48) & imm_in & rd_data(31 downto 0);
            elsif li_location = "11" then
                alu_output <= imm_in & rd_data(47 downto 0);
            end if;
        ------------------------------------------------------------------------
        
        ------------------------------------------------------------------------
        -- multipl-add and multiply-subtract
        -- 2^31 - 1 = 2147483647
        -- -2^31 = -2147483648
        -- logic of "01" (example of lower 32 bit):
        --       1. compute the result using signed operation
        --       2. check rs3(15) and rs2(15): 00 or 11 means postive result, hence xor
        --       3. if positive, check rs1(31): 0 means positive, so adding might saturate
        --                     if result > x"7FFFFFFF" (2^31 - 1) then saturate
        --          if negative, 1 means negative, so - add - can yield saturate
        --                     if result > x"80000000" (-2^31) then saturate
        --                          greater than because unsigned vectors
        ------------------------------------------------------------------------
        elsif ALUcontrol_in = "01" then
            if MAMS_in = "00" then
                MAMS_result1 := std_logic_vector(signed(rs3_data(15 downto 0))*signed(rs2_data(15 downto 0)) + signed(rs1_data(31 downto 0)));
                if not(rs3_data(15) xor rs2_data(15)) then
                    if rs1_data(31) = '0' then
                        if MAMS_result1 > x"7FFFFFFF" then
                            MAMS_result1 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif (rs3_data(15) xor rs2_data(15)) then
                    if rs1_data(31) = '1' then
                        if MAMS_result1 >  x"80000000" then
                            MAMS_result1 := x"80000000";
                        end if;
                    end if;
                end if;
                MAMS_result2 := std_logic_vector((signed(rs3_data(47 downto 32)))*signed(rs2_data(47 downto 32)) + signed(rs1_data(63 downto 32)));
                if not(rs3_data(47) xor rs2_data(47)) then
                    if rs1_data(63) = '0' then
                        if MAMS_result2 > x"7FFFFFFF" then
                            MAMS_result2 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif (rs3_data(47) xor rs2_data(47)) then
                    if rs1_data(63) = '1' then
                        if MAMS_result2 >  x"80000000" then
                            MAMS_result2 := x"80000000";
                        end if;
                    end if;
                end if;
                alu_output <= MAMS_result2 & MAMS_result1;
                
                
            elsif MAMS_in = "01" then
                MAMS_result1 := std_logic_vector(signed(rs3_data(31 downto 16))*signed(rs2_data(31 downto 16)) + signed(rs1_data(31 downto 0)));
                if not(rs3_data(31) xor rs2_data(31)) then
                    if rs1_data(31) = '0' then
                        if MAMS_result1 > x"7FFFFFFF" then
                            MAMS_result1 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif (rs3_data(31) xor rs2_data(31)) then
                    if rs1_data(31) = '1' then
                        if MAMS_result1 >  x"80000000" then
                            MAMS_result1 := x"80000000";
                        end if;
                    end if;
                end if;
                MAMS_result2 := std_logic_vector((signed(rs3_data(63 downto 48)))*signed(rs2_data(63 downto 48)) + signed(rs1_data(63 downto 32)));
                if not(rs3_data(63) xor rs2_data(63)) then
                    if rs1_data(63) = '0' then
                        if MAMS_result2 > x"7FFFFFFF" then
                            MAMS_result2 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif (rs3_data(63) xor rs2_data(63)) then
                    if rs1_data(63) = '1' then
                        if MAMS_result2 >  x"80000000" then
                            MAMS_result2 := x"80000000";
                        end if;
                    end if;
                end if;
                alu_output <= MAMS_result2 & MAMS_result1;
            
            
            elsif MAMS_in = "10" then
                MAMS_result1 := std_logic_vector(signed(rs1_data(31 downto 0)) - signed(rs3_data(15 downto 0))*signed(rs2_data(15 downto 0)));
                if rs3_data(15) xor rs2_data(15) then
                    if rs1_data(31) = '0' then
                        if MAMS_result1 > x"7FFFFFFF" then
                            MAMS_result1 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif not(rs3_data(15) xor rs2_data(15)) then
                    if rs1_data(31) = '1' then
                        if MAMS_result1 >  x"80000000" then
                            MAMS_result1 := x"80000000";
                        end if;
                    end if;
                end if;
                MAMS_result2 := std_logic_vector(signed(rs1_data(63 downto 32)) - signed(rs3_data(47 downto 32))*signed(rs2_data(47 downto 32)));
                if rs3_data(47) xor rs2_data(47) then
                    if rs1_data(63) = '0' then
                        if MAMS_result2 > x"7FFFFFFF" then
                            MAMS_result2 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif not(rs3_data(47) xor rs2_data(47)) then
                    if rs1_data(63) = '1' then
                        if MAMS_result2 >  x"80000000" then
                            MAMS_result2 := x"80000000";
                        end if;
                    end if;
                end if;
                alu_output <= MAMS_result2 & MAMS_result1;
                
            -- for subtraction, positive - negative will get greater saturate
            -- negative - positive will get lower saturate
            elsif MAMS_in = "11" then
                MAMS_result1 := std_logic_vector(signed(rs1_data(31 downto 0)) - signed(rs3_data(31 downto 16))*signed(rs2_data(31 downto 16)));
                if rs3_data(31) xor rs2_data(31) then
                    if rs1_data(31) = '0' then
                        if MAMS_result1 > x"7FFFFFFF" then
                            MAMS_result1 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif not(rs3_data(31) xor rs2_data(31)) then
                    if rs1_data(31) = '1' then
                        if MAMS_result1 >  x"80000000" then
                            MAMS_result1 := x"80000000";
                        end if;
                    end if;
                end if;
                MAMS_result2 := std_logic_vector(signed(rs1_data(63 downto 32)) - signed(rs3_data(63 downto 48))*signed(rs2_data(63 downto 48)));
                if rs3_data(63) xor rs2_data(63) then
                    if rs1_data(63) = '0' then
                        if MAMS_result2 > x"7FFFFFFF" then
                            MAMS_result2 := x"7FFFFFFF";
                        end if;
                    end if;
                elsif not(rs3_data(63) xor rs2_data(63)) then
                    if rs1_data(63) = '1' then
                        if MAMS_result2 >  x"80000000" then
                            MAMS_result2 := x"80000000";
                        end if;
                    end if;
                end if;
                alu_output <= MAMS_result2 & MAMS_result1;
			end if;
                
        ------------------------------------------------------------------------
        
        ------------------------------------------------------------------------
        -- opcode operations
        ------------------------------------------------------------------------
        elsif ALUcontrol_in = "00" then
        -- nop
        if std_match(opcode, nop_logic) then
        	null;
        -- bcw
        elsif std_match(opcode, bcw_logic) then
            alu_output(63 downto 32) <= rs1_data(31 downto 0);
            alu_output(31 downto 0) <= rs1_data(31 downto 0);
            
        -- and
        elsif std_match(opcode, and_logic) then
            alu_output <= rs2_data and rs1_data;
            
        -- or
        elsif std_match(opcode, or_logic) then
            alu_output <= rs2_data or rs1_data;
        
        -- popcnth
        elsif std_match(opcode,popcnth_logic) then
            for i in 63 downto 0 loop
                if rs1_data(i) = '1' then
                    if (i >= 48) then
                        count4 := count4 + 1;
                    elsif (i >= 32) then
                        count3 := count3 + 1;
                    elsif (i >= 16) then
                        count2 := count2 + 1;
                    elsif (i >= 0) then
                        count1 := count1 + 1;
                    end if;
                end if;
            end loop;
            
            alu_output <= std_logic_vector(to_unsigned(count4,16)) & std_logic_vector(to_unsigned(count3,16)) & std_logic_vector(to_unsigned(count2,16)) & std_logic_vector(to_unsigned(count1,16));
            
        -- clz
        elsif std_match(opcode,clz_logic) then
            for i in 63 downto 32 loop
                if rs1_data(i) = '0' then
                    count2 := count2 + 1;
                elsif rs1_data(i) = '1' then
                    exit;
                end if;
            end loop;
            for i in 31 downto 0 loop
                if rs1_data(i) = '0' then
                    count1 := count1 + 1;
                elsif rs1_data(i) = '1' then
                    exit;
                end if;
            end loop;
        	alu_output <= std_logic_vector(to_unsigned(count2, 32)) & std_logic_vector(to_unsigned(count1,32));
            
        -- rot (equivalent to ror in VHDL)
        elsif std_match(opcode, rot_logic) then
            shift_amt := to_integer(unsigned(rs2_data(5 downto 0)));
            -- debug purposes
            report "Value of shift is" & integer'image(shift_amt);
            alu_vec := rs1_data;
            if shift_amt /= 0 then
                alu_vec := alu_vec ror shift_amt;
            end if;
            alu_output <= alu_vec;
            
        -- shlhi
        elsif std_match(opcode,shlhi_logic) then
            shlhi_int := to_integer(unsigned(rs2_data(3 downto 0)));
            alu_var(63 downto 48) := to_bitvector(rs1_data(63 downto 48)) sll shlhi_int;
            alu_var(47 downto 32) := to_bitvector(rs1_data(47 downto 32)) sll shlhi_int;
            alu_var(31 downto 16) := to_bitvector(rs1_data(31 downto 16)) sll shlhi_int;
            alu_var(15 downto 0) := to_bitvector(rs1_data(15 downto 0)) sll shlhi_int;
            alu_output <= to_stdlogicvector(alu_var);
            
        -- a
        elsif std_match(opcode,a_logic) then
            word_temp0 := std_logic_vector(unsigned(rs1_data(31 downto 0)) + unsigned(rs2_data(31 downto 0)));
            word_temp1 := std_logic_vector(unsigned(rs1_data(63 downto 32)) + unsigned(rs2_data(63 downto 32)));
            alu_output <= word_temp1 & word_temp0;
      
        -- sfw
        elsif std_match(opcode,sfw_logic) then
            word_temp0 := std_logic_vector(unsigned(rs1_data(31 downto 0)) - unsigned(rs2_data(31 downto 0)));
            word_temp1 := std_logic_vector(unsigned(rs1_data(63 downto 32)) - unsigned(rs2_data(63 downto 32)));
            alu_output <= word_temp1 & word_temp0;
            
        -- ah
        elsif std_match(opcode, ah_logic) then
            temp0 := std_logic_vector(unsigned(rs1_data(15 downto 0)) + unsigned(rs2_data(15 downto 0)));
            temp1 := std_logic_vector(unsigned(rs1_data(31 downto 16)) + unsigned(rs2_data(31 downto 16)));
            temp2 := std_logic_vector(unsigned(rs1_data(47 downto 32)) + unsigned(rs2_data(47 downto 32)));
            temp3 := std_logic_vector(unsigned(rs1_data(63 downto 48)) + unsigned(rs2_data(63 downto 48)));
            alu_output <= temp3 & temp2 & temp1 & temp0;
            
        -- sfh
        elsif std_match(opcode, sfh_logic) then
            temp0 := std_logic_vector(unsigned(rs1_data(15 downto 0)) - unsigned(rs2_data(15 downto 0)));
            temp1 := std_logic_vector(unsigned(rs1_data(31 downto 16)) - unsigned(rs2_data(31 downto 16)));
            temp2 := std_logic_vector(unsigned(rs1_data(47 downto 32)) - unsigned(rs2_data(47 downto 32)));
            temp3 := std_logic_vector(unsigned(rs1_data(63 downto 48)) - unsigned(rs2_data(63 downto 48)));
            alu_output <= temp3 & temp2 & temp1 & temp0;
            
        -- ahs
        elsif std_match(opcode, ahs_logic) then
            temp0 := std_logic_vector(signed(rs1_data(15 downto 0)) + signed(rs2_data(15 downto 0)));
            temp1 := std_logic_vector(signed(rs1_data(31 downto 16)) + signed(rs2_data(31 downto 16)));
            temp2 := std_logic_vector(signed(rs1_data(47 downto 32)) + signed(rs2_data(47 downto 32)));
            temp3 := std_logic_vector(signed(rs1_data(63 downto 48)) + signed(rs2_data(63 downto 48)));
            
            if not(rs1_data(15) and rs2_data(15)) then
                if temp0 > x"7FFF" then
                    temp0 := x"7FFF";
                end if;
            elsif rs1_data(15) and rs2_data(15) then
                if temp0 > x"8000" then
                    temp0 := x"8000";
                end if;
            end if;
            if not(rs1_data(31) and rs2_data(31)) then
                if temp1 > x"7FFF" then
                    temp1 := x"7FFF";
                end if;
            elsif rs1_data(31) and rs2_data(31) then
                if temp1 > x"8000" then
                    temp1 := x"8000";
                end if;
            end if;
            if not(rs1_data(47) and rs2_data(47)) then
                if temp2 > x"7FFF" then
                    temp2 := x"7FFF";
                end if;
            elsif rs1_data(47) and rs2_data(47) then
                if temp2 > x"8000" then
                    temp2 := x"8000";
                end if;
            end if;
            if not(rs1_data(63) and rs2_data(63)) then
                if temp3 > x"7FFF" then
                    temp3 := x"7FFF";
                end if;
            elsif rs1_data(63) and rs2_data(63) then
                if temp3 > x"8000" then
                    temp3 := x"8000";
                end if;
            end if;
        
            alu_output <= temp3 & temp2 & temp1 & temp0;
            
            
        -- sfhs
        -- subtracting rs2 from rs1 
        -- positive - negatvie = greater saturation
        -- negative - positive = less saturation
        elsif std_match(opcode,sfhs_logic) then
            temp0 := std_logic_vector(signed(rs1_data(15 downto 0)) - signed(rs2_data(15 downto 0)));
            temp1 := std_logic_vector(signed(rs1_data(31 downto 16)) - signed(rs2_data(31 downto 16)));
            temp2 := std_logic_vector(signed(rs1_data(47 downto 32)) - signed(rs2_data(47 downto 32)));
            temp3 := std_logic_vector(signed(rs1_data(63 downto 48)) - signed(rs2_data(63 downto 48)));
            
            if rs1_data(15) and not(rs2_data(15)) then
                if temp0 > x"7FFF" then
                    temp0 := x"7FFF";
                end if;
            elsif not(rs1_data(15)) and rs2_data(15) then
                if temp0 > x"8000" then
                    temp0 := x"8000";
                end if;
            end if;
            if rs1_data(31) and not(rs2_data(31)) then
                if temp1 > x"7FFF" then
                    temp1 := x"7FFF";
                end if;
            elsif not(rs1_data(31)) and rs2_data(31) then
                if temp1 > x"8000" then
                    temp1 := x"8000";
                end if;
            end if;
            if rs1_data(47) and not(rs2_data(47)) then
                if temp2 > x"7FFF" then
                    temp2 := x"7FFF";
                end if;
            elsif not(rs1_data(47)) and rs2_data(47) then
                if temp2 > x"8000" then
                    temp2 := x"8000";
                end if;
            end if;
            if rs1_data(63) and not(rs2_data(63)) then
                if temp3 > x"7FFF" then
                    temp3 := x"7FFF";
                end if;
            elsif not(rs1_data(63)) and rs2_data(63) then
                if temp3 > x"8000" then
                    temp3 := x"8000";
                end if;
            end if;
        
            alu_output <= temp3 & temp2 & temp1 & temp0;
            
            
        -- mpyu
        elsif std_match(opcode,mpyu_logic) then
            alu_output(63 downto 32) <= std_logic_vector(unsigned(rs2_data(47 downto 32)) * unsigned(rs1_data(47 downto 32)));
            alu_output(31 downto 0) <= std_logic_vector(unsigned(rs2_data(15 downto 0)) * unsigned(rs1_data(15 downto 0)));
        
        -- absdb
        elsif std_match(opcode,absdb_logic) then
            alu_output(63 downto 56) <= std_logic_vector(abs(signed((unsigned(rs2_data(63 downto 56))) - unsigned(rs1_data(63 downto 56)))));
            alu_output(55 downto 48) <= std_logic_vector(abs(signed((unsigned(rs2_data(55 downto 48))) - unsigned(rs1_data(55 downto 48)))));
            alu_output(47 downto 40) <= std_logic_vector(abs(signed((unsigned(rs2_data(47 downto 40))) - unsigned(rs1_data(47 downto 40)))));
            alu_output(39 downto 32) <= std_logic_vector(abs(signed((unsigned(rs2_data(39 downto 32))) - unsigned(rs1_data(39 downto 32)))));
            alu_output(31 downto 24) <= std_logic_vector(abs(signed((unsigned(rs2_data(31 downto 24))) - unsigned(rs1_data(31 downto 24)))));
            alu_output(23 downto 16) <= std_logic_vector(abs(signed((unsigned(rs2_data(23 downto 16))) - unsigned(rs1_data(23 downto 16)))));
            alu_output(15 downto 8) <= std_logic_vector(abs(signed((unsigned(rs2_data(15 downto 8))) - unsigned(rs1_data(15 downto 8)))));
            alu_output(7 downto 0) <= std_logic_vector(abs(signed((unsigned(rs2_data(7 downto 0))) - unsigned(rs1_data(7 downto 0)))));
       
       end if;
       end if;
    end process;
end alu_arch;
    