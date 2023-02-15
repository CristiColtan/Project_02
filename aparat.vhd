----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/30/2022 04:53:55 PM
-- Design Name: 
-- Module Name: aparat - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity aparat is
    Port (
        Anodes: out std_logic_vector (7 downto 0);
        Segments: out std_logic_vector (7 downto 0);
        Cappucino: in std_logic := '0';
        Americano: in std_logic := '0';
        Ceai: in std_logic := '0';
        
        Reset: in std_logic := '0';
        Clock: in std_logic;
        Coins: in std_logic := '0';
        
        Idle: out std_logic;
        Preparing: out std_logic;
        Not_Enough_Money: out std_logic
        
        );
end aparat;

architecture Behavioral of aparat is
    signal slowClock: std_logic:= '0';
 
    signal wallet: integer := 0;
    signal drinkCounter: integer:= 0;
    signal errorCounter: integer:= 0;
    
    signal led_Idle: std_logic := '1';
    signal led_Preparing: std_logic := '0';
    signal led_Not_Enough_Money: std_logic := '0';

begin
    generateslowClock: process(Clock)
    
    variable counter: integer := 0;
    
    begin
    if rising_edge(Clock) then
    
        counter := counter + 1;
        if counter > 50000 then
            counter := 0;
            slowClock <= not slowClock;
            
        end if;
    end if;
    end process;
    
    machine: process(slowClock, drinkCounter, Reset, wallet, Coins, Americano, Cappucino, Ceai)
    begin

    if rising_edge(Coins) then    
        wallet <= wallet + 1;
    end if;
    
    if rising_edge(Reset) then
        wallet <= 0;
    end if;
    
    if led_Preparing = '1' then
        led_Idle <= '0';
        led_Not_Enough_Money <= '0';
        
        if drinkCounter > 0 then
            if rising_edge (slowClock) then
                drinkCounter <= drinkCounter -1;
            end if;
        else
                led_Idle <= '1';  
        end if;
    end if;
    
    if led_Not_Enough_Money = '1' then
        led_Idle <= '0';
        
        if errorCounter > 0 then
         if rising_edge (slowClock) then
            errorCounter <= errorCounter -1;
            end if;
        else
            led_Idle <= '1';
        
        end if;
    end if;
    
    if led_Idle = '1' then
        led_Preparing <= '0';
        led_Not_Enough_Money <= '0';
        
        if Americano = '1' then
            if wallet > 2 then
                led_Idle <= '0';
                wallet <= wallet - 3;
                drinkCounter <= 5;
                led_Preparing <= '1';
                
            else
                errorCounter <= 5;
                led_Not_Enough_Money <= '1';
            end if;
        end if;
        
        if Cappucino = '1' then
            if wallet > 3 then
                led_Idle <= '0';
                wallet <= wallet - 4;
                drinkCounter <= 7;
                led_Preparing <= '1';
            else
                errorCounter <= 5;
                led_Not_Enough_Money <= '1';
            end if;
        end if;
        
        if Ceai = '1' then
            if wallet > 1 then
                led_Idle <= '0';
                wallet <= wallet - 2;
                drinkCounter <= 4;
                led_Preparing <= '1';
            else
                errorCounter <= 5;
                led_Not_Enough_Money <= '1';
            end if;
        end if;
        
    end if;    
    end process;
    
    --aici trebuie facut un baleaj foarte rapid intre drinkCounter si wallet
    --incat sa para ca anodes de 0 si anodes de 1 apar in acelasi timp
    --nu stiu cum
    
    BCD_screen: process(drinkCounter)
    begin
       Anodes<="01111111";
       case drinkCounter is
            when 0 => Segments <= "00000011";
            when 1 => Segments <= "10011111";
            when 2 => Segments <= "00100101";
            when 3 => Segments <= "00001101";
            when 4 => Segments <= "10011001";
            when 5 => Segments <= "01001001";
            when 6 => Segments <= "01000001";
            when 7 => Segments <= "00011111";
            when others => Segments <="10000011";
       end case;
end process; 

    Idle <= led_Idle;
    Preparing <= led_Preparing;
    Not_Enough_Money <= led_Not_Enough_Money;
end Behavioral;






