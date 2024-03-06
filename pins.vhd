LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY pins IS
  Port (clk      : IN    STD_LOGIC ;
        reset_l  : IN    STD_LOGIC ;
        a        : IN    STD_lOGIC_VECTOR(1 DOWNTO 0) ;
        d        : INOUT STD_lOGIC_VECTOR(31 DOWNTO 0) ;
        ce       : IN    STD_LOGIC ;
        we       : IN    STD_LOGIC ;
        oe       : IN    STD_LOGIC ;
        io       : INOUT STD_lOGIC_VECTOR(31 DOWNTO 0));
END pins ;

ARCHITECTURE mine OF pins IS

    SIGNAL dir          : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
    SIGNAL outbit       : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
    SIGNAL resv         : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
    SIGNAL io_tmp       : STD_LOGIC_VECTOR(31 DOWNTO 0) ;   
    SIGNAL io_sync      : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
    
BEGIN

    dirreg: PROCESS(clk)
    BEGIN
       IF (clk = '1' AND clk'event) THEN
         IF (reset_l = '0') THEN
            dir  <= "00000000000000000000000000000000" ;
         ELSIF (a = "00" AND ce = '1' AND we = '1') THEN
            dir <= d ;
         END IF ;
      END IF ;
   END PROCESS ;

   d <= dir WHEN (a = "00" AND ce = '1' AND oe = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;

   outbitreg: PROCESS(clk)
   BEGIN
      IF (clk = '1' AND clk'event) THEN
         IF (reset_l = '0') THEN
            outbit  <= "00000000000000000000000000000000" ;
         ELSIF (a = "01" AND ce = '1' AND we = '1') THEN
            outbit <= d ;
         END IF;
      END IF ;
   END PROCESS ;

   d <= outbit WHEN (a = "01" AND ce = '1' AND oe = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;

   resvreg: PROCESS(clk)
   BEGIN
      IF (clk = '1' AND clk'event) THEN
         IF (reset_l = '0') THEN
            resv  <= "00000000000000000000000000000000" ;
         ELSIF (a = "11" AND ce = '1' AND we = '1') THEN
            resv <= d ;
         END IF;
      END IF ;
   END PROCESS ;

   d <= resv WHEN (a = "11" AND ce = '1' AND oe = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;

   iosync:PROCESS(clk)   
   BEGIN      
      IF (clk'EVENT AND clk = '1') THEN            
          io_tmp  <= io ;         
          io_sync <= io_tmp ;  
      END IF;      
   END PROCESS;

   d <= io_sync WHEN (a = "10" AND ce = '1' AND oe = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;

   mytristate:PROCESS(dir,outbit)
   BEGIN
      FOR i IN 0 TO 31 LOOP
         IF dir(i) = '1' THEN
            io(i) <= outbit(i) ;
         ELSE
            io(i) <= 'Z' ;
         END IF ;
      END LOOP ;
   END PROCESS mytristate ;

END mine ;
