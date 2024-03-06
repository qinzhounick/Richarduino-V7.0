--- I2C design for the 48 MHz RichArduino with start/stop bits added to byte transfer data
--- Copyright William D. Richard, Ph.D.
--- April 5, 2022

---UNTESTED!

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

ENTITY i2c IS
  PORT (clk           : IN      STD_LOGIC ;
        reset_l       : IN      STD_LOGIC ;
        scl           : OUT     STD_LOGIC ;
        sda           : INOUT   STD_LOGIC ;
        d             : INOUT   STD_LOGIC_VECTOR(31 DOWNTO 0) ;
        a             : IN      STD_LOGIC_VECTOR(1 DOWNTO 0) ;
        ce            : IN      STD_LOGIC ;
        oe            : IN      STD_LOGIC ;
        we            : IN      STD_LOGIC) ;
END i2c ;

ARCHITECTURE rtl OF i2c IS

   SIGNAL tx_counter     : STD_LOGIC_VECTOR(12 DOWNTO 0) ;
   SIGNAL tx_data_sav    : STD_LOGIC_VECTOR(7 DOWNTO 0) ;

   SIGNAL tx_busy        : STD_LOGIC ;
   SIGNAL tx_start       : STD_LOGIC ;

   SIGNAL ack            : STD_LOGIC ;

   SIGNAL start          : STD_LOGIC ;
   SIGNAL stop           : STD_LOGIC ;

BEGIN

--- THIS IS THE BUS INTERFACE

   d <= "0000000000000000000000000000000" & (tx_busy) WHEN (a = "00" AND oe = '1' AND ce = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;
   d <= "000000000000000000000000" & tx_data_sav      WHEN (a = "01" AND oe = '1' AND ce = '1' AND ce = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;
   d <= "0000000000000000000000000000000" & ack       WHEN (a = "10" AND oe = '1' AND ce = '1') ELSE "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" ;

   tx_start <= '1' WHEN (a = "01" AND ce = '1' AND we = '1') ELSE '0';

--- THIS IS THE TRANSMITTER

   trans_counter:PROCESS(clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF reset_l = '0' THEN
            tx_counter  <= "0000000000000" ;
            tx_busy     <= '0' ;
            tx_data_sav <= "00000000" ;
            scl         <= 'Z' ;
            sda         <= 'Z' ;
            ack         <= '0' ;
         ELSIF (tx_busy  = '0') THEN
            IF (tx_start = '1') THEN
               tx_busy     <= '1' ; 
               tx_counter  <= tx_counter + 1 ;
               tx_data_sav <= d(7 DOWNTO 0) ;
               ack         <= '0' ;
               start       <= d(9) ;
               stop        <= d(8) ;
               ---sda         <= '0' ;
            END IF ;
         ELSIF (tx_counter = 5540) THEN --- 
               tx_busy    <= '0' ;
               tx_counter <= "0000000000000" ;
         ELSE
            tx_counter <= tx_counter + 1 ;
            IF (tx_counter = 60 AND start = '1') THEN --- INSERT START CONDITION
               sda <= '0' ;
            END IF ;
            IF (tx_counter = 120) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 240) THEN
               IF tx_data_sav(7) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 360) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 600) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 740) THEN
               IF tx_data_sav(6) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 860) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 1100) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 1220) THEN
               IF tx_data_sav(5) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 1340) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 1580) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 1700) THEN
               IF tx_data_sav(4) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 1820) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 2060) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 2180) THEN
               IF tx_data_sav(3) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 2300) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 2540) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 2660) THEN
               IF tx_data_sav(2) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 2780) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 3020) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 3140) THEN
               IF tx_data_sav(1) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 3260) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 3500) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 3620) THEN
               IF tx_data_sav(0) = '0' THEN
                  sda <= '0' ;
               ELSE
                  sda <= 'Z' ;
               END IF ;
            END IF ;
            IF (tx_counter = 3740) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 3980) THEN
               scl <= '0' ;
            END IF ;
            IF (tx_counter = 4100) THEN
               sda <= 'Z' ;
            END IF ;
            IF (tx_counter = 4220) THEN
               scl <= 'Z' ;
            END IF ;
            IF (tx_counter = 4340) THEN --- Capture ACK
               ack <= NOT(sda) ; --- for simulation testing!
               ---IF sda = '0' THEN
               ---   ack <= '1' ;
               ---ELSE
               ---   ack <= '0' ;
               ---END IF ;
            END IF ;
            IF (tx_counter = 4460) THEN
               scl <= '0' ;
            END IF ;

            IF (tx_counter = 4580 AND stop = '1') THEN --- STOP CONDITION
               sda <= '0' ;
            END IF ;

            IF (tx_counter = 4700 AND stop = '1') THEN --- STOP CONDITION
               scl <= 'Z' ;
            END IF ;

            IF (tx_counter = 5060 AND stop = '1') THEN --- STOP CONDITION
               sda <= 'Z' ;
            END IF ;
            
         END IF ;
      END IF;
   end process;

END rtl;