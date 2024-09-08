----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2024 06:13:20 PM
-- Design Name: 
-- Module Name: xadc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity myxadc is
  Port (clk         : IN STD_LOGIC ;
        reset_l     : IN STD_LOGIC ;
        data        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) ;
        next_h      : OUT STD_LOGIC ;
        vauxn4      : IN STD_LOGIC ;
        vauxp4      : IN STD_LOGIC ;
        vauxn12     : IN STD_LOGIC ;
        vauxp12     : IN STD_LOGIC );
end myxadc;

architecture Behavioral of myxadc is

   COMPONENT xadc_wiz_0
   PORT
   (
    daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
    vauxp4          : in  STD_LOGIC;                         -- Auxiliary Channel 4
    vauxn4          : in  STD_LOGIC;
    vauxp12         : in  STD_LOGIC;                         -- Auxiliary Channel 12
    vauxn12         : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC);
   END COMPONENT;
   
   SIGNAL daddr_in        : STD_LOGIC_VECTOR (6 downto 0);    
   SIGNAL den_in          : STD_LOGIC;                         
   SIGNAL di_in           : STD_LOGIC_VECTOR (15 downto 0); 
   SIGNAL dwe_in          : STD_LOGIC;                        
   SIGNAL do_out          : STD_LOGIC_VECTOR (15 downto 0);   
   SIGNAL drdy_out        : STD_LOGIC;                      
   SIGNAL dclk_in         : STD_LOGIC;                     
   SIGNAL reset_in        : STD_LOGIC;                
   SIGNAL busy_out        : STD_LOGIC;                       
   SIGNAL channel_out     : STD_LOGIC_VECTOR (4 downto 0);   
   SIGNAL eoc_out         : STD_LOGIC;                        
   SIGNAL eos_out         : STD_LOGIC;                     
   SIGNAL alarm_out       : STD_LOGIC;                     
   SIGNAL vp_in           : STD_LOGIC;                        
   SIGNAL vn_in           : STD_LOGIC;
      
   SIGNAL reset_h_temp     : STD_LOGIC;

begin
    xadc_wiz_01:xadc_wiz_0
    PORT MAP(daddr_in      => daddr_in     ,
             den_in        => den_in       ,         
             di_in         => di_in        ,    
             dwe_in        => dwe_in       ,   
             do_out        => do_out       ,    
             drdy_out      => drdy_out     ,    
             dclk_in       => dclk_in      ,    
             reset_in      => reset_in     ,    
             vauxp4        => vauxp4       ,    
             vauxn4        => vauxn4       ,    
             vauxp12       => vauxp12      ,   
             vauxn12       => vauxn12      ,    
             busy_out      => busy_out     ,   
             channel_out   => channel_out  ,    
             eoc_out       => eoc_out      , 
             eos_out       => eos_out      , 
             alarm_out     => alarm_out    , 
             vp_in         => vp_in        , 
             vn_in         => vn_in        ) ;
             
    den_in   <= eoc_out            ;
    vn_in    <= '0'                ;
    vp_in    <= '0'                ;
    daddr_in <= "0011100"          ;
    di_in    <= "0000000000000000" ;
    dwe_in   <= '0'                ;
    dclk_in  <= clk                ;
    next_h   <= drdy_out           ;
    
    clk_dout: PROCESS (clk)
    BEGIN
       IF (clk'EVENT AND clk='1') THEN
          reset_h_temp <= NOT(reset_l) ;
          reset_in <= reset_h_temp;
          IF (reset_l = '0') THEN
             data <= "00000000";
          ELSE
             IF(drdy_out = '1') THEN
                 data <= do_out(15 DOWNTO 8) ;
             END IF;
          END IF;
       END IF;
     END PROCESS clk_dout;
    

end Behavioral;
