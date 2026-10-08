----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2026 11:36:38
-- Design Name: 
-- Module Name: REGISTRE_DCC - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- ###################################################################################
-- ###################################################################################
-- #                 Module qui va shifter la Trame ou la charger                    #
-- #                                                                                 #
-- # clk       : Horloge 100MHz (celui de la carte)                                  #
-- # reset     : Signal de r inialisation                                            #
-- # Trame_DCC : Trame d'entr e, qui va  tre charg                                   #
-- # COM_REG   : Signal envoy  par la MAE pour soit charg  soit shifter Trame_DCC    #
-- # Reg_DCC   : Sortie du bit de poid fort de la trame Shifter                      #
-- #                                                                                 #
-- ###################################################################################
-- ###################################################################################



entity REGISTRE_DCC is
    Port ( clk, reset : in STD_LOGIC;
           Trame_DCC : in STD_LOGIC_VECTOR (50 downto 0);
           COM_REG   : in STD_LOGIC_VECTOR (1 downto 0);
           Reg_DCC   : out STD_LOGIC
          ); -- taille à modifier selon la MAE
end REGISTRE_DCC;

architecture Behavioral of REGISTRE_DCC is

-- Signal qui va sauvegarder la trame et la shifter
signal Trame_SHF : STD_LOGIC_VECTOR (50 downto 0);

begin
    
    -- S quentiel sur la clock
    process(clk, reset) 
    begin 
    
        -- Reset actif, envoie d'une suite de 0
        if(reset = '1') then 
            Trame_SHF <= (others => '0');
            
        elsif(rising_edge(clk)) then 
            -- Si COM_REG = 2, mode load, chargement de Trame_DCC dans Trame_SHF
            if    (COM_REG = 2) then Trame_SHF <= Trame_DCC;
            -- Si COM_REG = 1, mode shift, shift de un vers la gauche Trame_SHF
            elsif (COM_REG = 1) then Trame_SHF <= Trame_SHF(49 downto 0) & '0';
            
            else                     Trame_SHF <= Trame_SHF;
            
            end if;
        end if;
    end process;
    
    -- Sortie combinatoire, bit de poids fort de Trame_SHF en sortie
    Reg_DCC <= Trame_SHF(50);
end Behavioral;
