---RICHARDUINO BOOT MONITOR
---Ulysses Atkeson, Spring 2022
---Edited by WDR 1/11/23 to change version echo to ASCII
---Original code for downloader portion done by M. Konst

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY eprom IS
   PORT (d        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
         address  : IN  STD_LOGIC_VECTOR(9 DOWNTO 0) ;
         ce_l     : IN  STD_LOGIC ;
         oe_l     : IN  STD_LOGIC) ;
   END eprom ;

ARCHITECTURE behavioral OF eprom IS

   SIGNAL data    : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   SIGNAL sel     : STD_LOGIC_VECTOR(31 DOWNTO 0) ;

BEGIN

   sel <= "00000000000000000000" & address & "00" ;

   WITH sel  SELECT
   data <=
      X"2fc1ffe8" WHEN X"00000000" , 
      X"2f81ffec" WHEN X"00000004" , 
      X"2f400050" WHEN X"00000008" , 
      X"2f001000" WHEN X"0000000c" , 
      X"2ec00050" WHEN X"00000010" , 
      X"2e80012c" WHEN X"00000014" , 
      X"2e40013c" WHEN X"00000018" , 
      X"2e00014c" WHEN X"0000001c" , 
      X"2dc0015c" WHEN X"00000020" , 
      X"2d8000e4" WHEN X"00000024" , 
      X"2d400036" WHEN X"00000028" , -- This is the version number!
      X"2a400090" WHEN X"0000002c" , 
      X"2a0000a8" WHEN X"00000030" , 
      X"29c000bc" WHEN X"00000034" , 
      X"298000d0" WHEN X"00000038" , 
      X"294000ff" WHEN X"0000003c" , 
      X"2901ffe0" WHEN X"00000040" , 
      X"28c1ffe4" WHEN X"00000044" , 
      X"28801000" WHEN X"00000048" , 
      X"28400178" WHEN X"0000004c" , 
      X"0cbe0000" WHEN X"00000050" , 
      X"40372002" WHEN X"00000054" , 
      X"0c7c0000" WHEN X"00000058" , 
      X"7423d000" WHEN X"0000005c" , 
      X"2a800108" WHEN X"00000060" , 
      X"40350002" WHEN X"00000064" , 
      X"6c21fffe" WHEN X"00000068" , 
      X"2a800090" WHEN X"0000006c" , 
      X"40350002" WHEN X"00000070" , 
      X"6c21fffc" WHEN X"00000074" , 
      X"2a8000e4" WHEN X"00000078" , 
      X"402d0002" WHEN X"0000007c" , 
      X"6c21ffff" WHEN X"00000080" , 
      X"2a8000f4" WHEN X"00000084" , 
      X"40350002" WHEN X"00000088" , 
      X"40360001" WHEN X"0000008c" , 
      X"0b1a0000" WHEN X"00000090" , 
      X"0c880000" WHEN X"00000094" , 
      X"40132003" WHEN X"00000098" , 
      X"d2d80018" WHEN X"0000009c" , 
      X"a2d65000" WHEN X"000000a0" , 
      X"1ac60000" WHEN X"000000a4" , 
      X"0c880000" WHEN X"000000a8" , 
      X"40112003" WHEN X"000000ac" , 
      X"d2d80010" WHEN X"000000b0" , 
      X"a2d65000" WHEN X"000000b4" , 
      X"1ac60000" WHEN X"000000b8" , 
      X"0c880000" WHEN X"000000bc" , 
      X"400f2003" WHEN X"000000c0" , 
      X"d2d80008" WHEN X"000000c4" , 
      X"a2d65000" WHEN X"000000c8" , 
      X"1ac60000" WHEN X"000000cc" , 
      X"0c880000" WHEN X"000000d0" , 
      X"400d2003" WHEN X"000000d4" , 
      X"a2d85000" WHEN X"000000d8" , 
      X"1ac60000" WHEN X"000000dc" , 
      X"40360001" WHEN X"000000e0" , 
      X"0c880000" WHEN X"000000e4" , 
      X"402d2003" WHEN X"000000e8" , 
      X"1d460000" WHEN X"000000ec" , 
      X"40360001" WHEN X"000000f0" , 
      X"6b1a0000" WHEN X"000000f4" , 
      X"2a800100" WHEN X"000000f8" , 
      X"40340001" WHEN X"000000fc" , 
      X"1b580000" WHEN X"00000100" , 
      X"40360001" WHEN X"00000104" , 
      X"4002d002" WHEN X"00000108" , 
      X"6b1a0000" WHEN X"0000010c" , 
      X"2a800118" WHEN X"00000110" , 
      X"40340001" WHEN X"00000114" , 
      X"1b780000" WHEN X"00000118" , 
      X"6f380004" WHEN X"0000011c" , 
      X"6b19fffc" WHEN X"00000120" , 
      X"4034c003" WHEN X"00000124" , 
      X"40040001" WHEN X"00000128" , 
      X"0cbe0000" WHEN X"0000012c" , 
      X"40352002" WHEN X"00000130" , 
      X"0c7c0000" WHEN X"00000134" , 
      X"e4220018" WHEN X"00000138" , 
      X"0cbe0000" WHEN X"0000013c" , 
      X"40332002" WHEN X"00000140" , 
      X"0c7c0000" WHEN X"00000144" , 
      X"e3e20010" WHEN X"00000148" , 
      X"0cbe0000" WHEN X"0000014c" , 
      X"40312002" WHEN X"00000150" , 
      X"0c7c0000" WHEN X"00000154" , 
      X"e3a20008" WHEN X"00000158" , 
      X"0cbe0000" WHEN X"0000015c" , 
      X"402f2002" WHEN X"00000160" , 
      X"0c7c0000" WHEN X"00000164" , 
      X"b360f000" WHEN X"00000168" , 
      X"b35ae000" WHEN X"0000016c" , 
      X"b35b1000" WHEN X"00000170" , 
      X"40140001" WHEN X"00000174" , 
      X"f8000000" WHEN X"00000178" , 
      X"00000000" WHEN OTHERS ;

   readprocess:PROCESS(ce_l,oe_l,data)
   begin
      IF (ce_l = '0' AND oe_l = '0') THEN
         d(31 DOWNTO 0) <= data ;
      else
	 d(31 DOWNTO 0) <= (OTHERS => 'Z') ;
      END IF;
   END PROCESS readprocess ;

END behavioral ;
