library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity xadc IS
   PORT ( clk       : IN  STD_LOGIC ;
          vauxp4          : in  STD_LOGIC ;
          vauxn4          : in  STD_LOGIC ;
          vauxp12         : in  STD_LOGIC ;
          vauxn12         : in  STD_LOGIC);
END xadc;

ARCHITECTURE mine of microphone IS

   SIGNAL mycount  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000" ;
   SIGNAL micarray : STD_LOGIC_VECTOR(254 DOWNTO 0) := (OTHERS => '0') ;
   SIGNAL data_tmp : STD_LOGIC_VECTOR(7 DOWNTO 0) ;

BEGIN

   m_lrsel <= '0' ;
   m_clk <= mycount(4) ;

   clkd:PROCESS(clk)
   BEGIN
      IF(clk'EVENT AND clk='1') THEN
        mycount <= mycount + 1 ;
        IF mycount(4 DOWNTO 0) = "01111" THEN
            micarray(254 DOWNTO 0) <= micarray(253 DOWNTO 0) & m_data ;
        END IF ;
        IF mycount(7 DOWNTO 0) = "00000000" THEN
            next_h <= '1' ;
        ELSE
            next_h <= '0' ;
        END IF ;
      END IF ;
   END PROCESS clkd ;
   
   makethemic:PROCESS(micarray)
      VARIABLE temp : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
   BEGIN
      temp := X"00" ;
      FOR i IN 0 TO 254 LOOP
         temp := temp + micarray(i) ;
      END LOOP ;
      data_tmp <= temp ;
   END PROCESS makethemic ;

---These FFs may not be needed; used to test timing during development
   PROCESS(clk)
   BEGIN
      IF(clk'EVENT AND clk='1') THEN
         data <= data_tmp ;
      END IF ;
   END PROCESS ;

END mine ;
