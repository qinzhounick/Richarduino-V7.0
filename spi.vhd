--- 115200 Baud UART design for the 48 MHz RichArduino
--- Copyright William D. Richard, Ph.D.
--- March 28, 2020

---UNFINISHED!

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

ENTITY spi IS
  PORT (clk           : IN      STD_LOGIC ;
        reset_l       : IN      STD_LOGIC ;
        --serial_in     : IN      STD_LOGIC ;
        mosi          : OUT     STD_LOGIC_VECTOR(7 DOWNTO 0) ;
        sclk          : OUT     STD_LOGIC ;
        cs_l          : OUT     STD_LOGIC ;
        serial_out    : OUT     STD_LOGIC ;
        d             : INOUT   STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        a             : IN      STD_LOGIC_VECTOR(1 DOWNTO 0) ;
        ce            : IN      STD_LOGIC ;
        oe            : IN      STD_LOGIC ;
        we            : IN      STD_LOGIC) ;
END spi ;

ARCHITECTURE rtl OF spi IS

   --COMPONENT fifo_generator_0
   --PORT (clk   : IN STD_LOGIC;
   --      srst  : IN STD_LOGIC;
   --      din   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
   --      wr_en : IN STD_LOGIC;
   --      rd_en : IN STD_LOGIC;
   --      dout  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
   --      full  : OUT STD_LOGIC;
   --      empty : OUT STD_LOGIC);
   --END COMPONENT;
   
   SIGNAL counter        : STD_LOGIC_VECTOR(11 DOWNTO 0) ;
   SIGNAL count          : STD_LOGIC ;
   --SIGNAL serial_in_int  : STD_LOGIC ;
   --SIGNAL serial_in_temp : STD_LOGIC ;
   SIGNAL tx_counter     : STD_LOGIC_VECTOR(12 DOWNTO 0) ;
   SIGNAL tx_data_sav    : STD_LOGIC_VECTOR(7 DOWNTO 0) ;

   --SIGNAL rx_data        : STD_LOGIC_VECTOR(7 DOWNTO 0) ;
   --SIGNAL rx_data_valid  : STD_LOGIC ;
   SIGNAL tx_busy        : STD_LOGIC ;
   SIGNAL tx_start       : STD_LOGIC ;
   SIGNAL tx_data        : STD_LOGIC_VECTOR(7 DOWNTO 0) ;

   --SIGNAL srst           : STD_LOGIC ;
   --SIGNAL full           : STD_LOGIC ;
   --SIGNAL empty          : STD_LOGIC ;
   --SIGNAL rd_en          : STD_LOGIC ;
   --SIGNAL dout           : STD_LOGIC_VECTOR(7 DOWNTO 0) ;


BEGIN

--- THIS IS THE BUS INTERFACE

   d <= "0000000000000000000000000000000" & (tx_busy) WHEN (a = "00" AND oe = '1' AND ce = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;
   --d <= "0000000000000000000000000000000" & (NOT(empty)) WHEN (a= "10" AND oe = '1' AND ce = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;
   --d <= "000000000000000000000000" & dout WHEN (a = "11" AND oe = '1'  AND ce = '1' AND ce = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;

   tx_start <= '1' WHEN (a = "01" AND ce = '1' AND we = '1') ELSE '0';
   tx_data <= d(7 DOWNTO 0) ;

   --rd_en <= '1' WHEN (a = "11" AND oe = '1'  AND ce = '1' AND ce = '1') ELSE '0' ;
   
   --- THIS IS THE RECEIVER

   --rec_counter:PROCESS(clk)
   --BEGIN
   --   IF (clk'EVENT AND clk = '1') THEN
   --      serial_in_temp <= serial_in ;
   --      serial_in_int  <= serial_in_temp ;
   --      IF reset_l = '0' THEN
   --         counter <= "000000000000" ;
   --         count   <= '0' ;
   --      ELSIF (count = '0') THEN
   --         IF (serial_in_int = '0') THEN
   --            count   <= '1' ; 
   --            counter <= counter + 1 ; 
   --         END IF ;
   --      ELSIF (counter = 208) THEN  --- Midpoint of start bit
   --         IF (serial_in_int = '0') THEN    --- Test start bit!
   --            counter <= counter + 1 ;
   --         ELSE
   --            count   <= '0' ; 
   --            counter <= "000000000000" ;
   --         END IF ;
   --      ELSIF (counter = 3958) THEN --- Midpoint of stop bit
   --            count   <= '0' ; 
   --            counter <= "000000000000" ;
   --      ELSE
   --         counter <= counter + 1 ;
   --         IF (counter = 625) THEN  --- Midoint of first data bit
   --            rx_data(0) <= serial_in_int ;
   --        END IF ;
   --         IF (counter = 1042) THEN --- Midpoint of second data bit
   --            rx_data(1) <= serial_in_int ;
   --         END IF ;
   --         IF (counter = 1458) THEN --- Midpoint of third data bit
   --            rx_data(2) <= serial_in_int ;
   --         END IF ;
   --         IF (counter = 1875) THEN --- Midpoint of fourth data bit
   --            rx_data(3) <= serial_in_int ;
   --         END IF ;
   --         IF (counter = 2292) THEN --- Midpoint of fifth data bit
   --            rx_data(4) <= serial_in_int ;
   --         END IF ;
   --         IF (counter = 2708) THEN --- Midoint of sixth data bit
   --            rx_data(5) <= serial_in_int ;
   --         END IF ;
   --         IF (counter = 3125) THEN --- Midpoint of seventh data bit
   --            rx_data(6) <= serial_in_int ;
   --         END IF ;
   --         IF (counter = 3542) THEN --- Midpoint of eighth data bit
   --            rx_data(7) <= serial_in_int ;
   --         END IF ;
   --      END IF ;
   --   END IF;
   --end process;


   --rx_data_valid <= '1' WHEN (counter = 3543) ELSE '0' ; --- 3542 + 1

   --srst <= NOT(reset_l) ;

   --myuartfifo:fifo_generator_0
   --PORT MAP (clk   => clk ,
   --          srst  => srst ,
   --          din   => rx_data ,
   --          wr_en => rx_data_valid ,
   --          rd_en => rd_en,
   --          dout  => dout,
   --          full  => full,
   --          empty => empty);

--- THIS IS THE TRANSMITTER

   trans_counter:PROCESS(clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF reset_l = '0' THEN
            tx_counter  <= "0000000000000" ;
            tx_busy     <= '0' ;
            tx_data_sav <= "00000000" ;
            serial_out  <= '1' ;
         ELSIF (tx_busy  = '0') THEN
            IF (tx_start = '1') THEN
               tx_busy     <= '1' ; 
               tx_counter  <= tx_counter + 1 ;
               tx_data_sav <= tx_data ;
               serial_out  <= '0' ;
            END IF ;
         ELSIF (tx_counter = 4167) THEN --- End of stop bit
               tx_busy    <= '0' ;      --- This count implies 1 stop bit!
               tx_counter <= "0000000000000" ;
         ELSE
            tx_counter <= tx_counter + 1 ;
            IF (tx_counter = 417) THEN  --- End of start bit
               serial_out <= tx_data_sav(0) ;
            END IF ;
            IF (tx_counter = 833) THEN  --- End if first data bit
               serial_out <= tx_data_sav(1) ;
            END IF ;
            IF (tx_counter = 1250) THEN --- End of second data bit
               serial_out <= tx_data_sav(2) ;
            END IF ;
            IF (tx_counter = 1667) THEN --- End of third data bit
               serial_out <= tx_data_sav(3) ;
            END IF ;
            IF (tx_counter = 2083) THEN --- End of fourth data bit
               serial_out <= tx_data_sav(4) ;
            END IF ;
            IF (tx_counter = 2500) THEN --- End of fifth data bit
               serial_out <= tx_data_sav(5) ;
            END IF ;
            IF (tx_counter = 2917) THEN --- End of sixth data bit
               serial_out <= tx_data_sav(6) ;
            END IF ;
            IF (tx_counter = 3333) THEN --- End of seventh data bit
               serial_out <= tx_data_sav(7) ;
            END IF ;
            IF (tx_counter = 3750) THEN --- End of eighth data bit
               serial_out <= '1' ;
            END IF ;
         END IF ;
      END IF;
   end process;

END rtl;
