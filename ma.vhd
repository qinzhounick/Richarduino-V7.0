--- 2018 Multimaster RSRC "ma" VHDL Code 
--- Current file name:  ma.vhd
--- Last Revised:  10/1/2016; 1:25 p.m.
--- Author:  WDR
--- Copyright:  William D. Richard, Ph.D.

LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;

ENTITY ma IS
   PORT (bus_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) ;
         address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
         clk     : IN  STD_LOGIC ;
         grant   : IN  STD_LOGIC ;
         ma_in   : IN  STD_LOGIC) ;
END ma ;

ARCHITECTURE behavioral OF ma IS

   SIGNAL address_int : STD_LOGIC_VECTOR(31 DOWNTO 0) ;

BEGIN

   mareg:PROCESS(clk)
   BEGIN
      IF (clk = '1' AND clk'EVENT) THEN
         IF (ma_in = '1') THEN
	        address_int(31 DOWNTO 0 ) <= bus_in(31 DOWNTO 0) ;
         END IF ;
      END IF ;
   END PROCESS mareg ; 

   pindrive:PROCESS(grant,address_int)
   BEGIN
      IF (grant = '1') THEN
         address <= address_int ;
      ELSE
         address <= (OTHERS => 'Z') ;
      END IF ;
   END PROCESS pindrive ;

END behavioral ;
