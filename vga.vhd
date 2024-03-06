LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY vga IS
   PORT (src_clk   : IN  STD_LOGIC ;
         ena       : IN  STD_LOGIC ;
         wea       : IN  STD_LOGIC_VECTOR(0 DOWNTO 0) ;
         addra     : IN  STD_LOGIC_VECTOR(18 DOWNTO 0) ;
         dina      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0) ;
         vga_clk   : IN  STD_LOGIC ;
         r         : OUT STD_LOGIC ;
         g         : OUT STD_LOGIC ;
         b         : OUT STD_LOGIC ;
         hs        : OUT STD_LOGIC ;
         vs        : OUT STD_LOGIC);
END vga ;

ARCHITECTURE mine OF vga IS

   SIGNAL h       : STD_LOGIC_VECTOR(9 downto 0) := "0000000000" ;
   SIGNAL v       : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000" ;
   SIGNAL addrb   : STD_LOGIC_VECTOR(18 DOWNTO 0) ;
   SIGNAL doutb   : STD_LOGIC_VECTOR(2 DOWNTO 0) ;
   SIGNAL vc      : STD_LOGIC_VECTOR(9 DOWNTO 0) ;
   SIGNAL hc      : STD_LOGIC_VECTOR(9 DOWNTO 0) ;
   
   COMPONENT blk_mem_gen_0
   PORT (clka  : IN  STD_LOGIC;
         ena   : IN  STD_LOGIC;
         wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
         addra : IN  STD_LOGIC_VECTOR(18 DOWNTO 0);
         dina  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         clkb  : IN  STD_LOGIC;
         addrb : IN  STD_LOGIC_VECTOR(18 DOWNTO 0);
         doutb : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
   END COMPONENT;
	
BEGIN
            
   myram:blk_mem_gen_0
   PORT MAP(clka  => src_clk ,
            ena   => ena ,
            wea   => wea ,
            addra => addra ,
            dina  => dina ,
            clkb  => vga_clk ,
            addrb => addrb ,
            doutb => doutb) ;

   vc <= v - 35 ;
   hc <= h - 143 ;
   addrb <= vc(8 DOWNTO 0) & hc(9 DOWNTO 0) ;

   horizontal:PROCESS(vga_clk)
   BEGIN
      IF (vga_clk = '1' AND vga_clk'EVENT) THEN
         IF h = 799 THEN
            h <= "0000000000" ;
         ELSE
            h <= h + 1 ;
         END IF ;
      END IF ;
   END PROCESS ;

   vertical:PROCESS(vga_clk)
   BEGIN
      IF (vga_clk = '1' AND vga_clk'EVENT) THEN
         IF h = 799 THEN
            IF v = 524 THEN
               v <= "0000000000" ;
            ELSE
               v <= v + 1 ;
            END IF ;
         END IF ;
      END IF ;
   END PROCESS ;

   sync:PROCESS(vga_clk)
   BEGIN
      IF (vga_clk = '1' AND vga_clk'EVENT) THEN
         IF h < 96 THEN
            hs <= '0' ;
         ELSE
            hs <= '1' ;
         END IF ;
         IF v < 523 THEN
            vs <= '1' ;
         ELSE
            vs <= '0' ;
         END IF ;
      END IF ;
   END PROCESS ;

   rgb:PROCESS(vga_clk)
   BEGIN
      IF (vga_clk = '1' AND vga_clk'EVENT) THEN
         IF (h > 143) AND (h < 784) AND (v > 34) AND (v < 515) THEN
            r <= doutb(2) ;
            b <= doutb(1) ;
            g <= doutb(0) ;
         ELSE
            r <= '0' ;
            g <= '0' ;
            b <= '0' ;
         END IF ;
      END IF ;
   END PROCESS ;

END mine ;
