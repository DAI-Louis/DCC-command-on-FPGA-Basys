----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2026 11:53:42
-- Design Name: 
-- Module Name: MAE - Behavioral
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

-- Lecture des autres modules nécessaires pour comprendre la MAE

-- #######################################################################################
-- #######################################################################################
-- #              Module de la MAE qui va gérer appeler les autres modules               #
-- #                                                                                     #
-- # Clk         : Horloge 100MHz (celui de la carte)                                    #
-- # reset       : Signal de réinialisation                                              #
-- # Fin_Tempo   : Fin de l'attente pour lire la prochaine trame                         #
-- # Fin_0       : Fin de l'attente de l'envoie du bit0, depuis BIT_0                    #
-- # Fin_1       : Fin de l'attente de l'envoie du bit1, depuis BIT_1                    #
-- # Reg_DCC     : Bit de poid de la trame, depuis Registre_DCC                          #
-- # Start_Tempo : Signal pour demander l'attente avant la lecture de la prochaine trame #
-- # Go_0        : Signal pour demander l'envoie d'un BIT_0                              #
-- # Go_1        : Signal pour demander l'envoie d'un BIT_0                              #
-- # Com_Reg     : Signal pour demander soit un Shift soit un Load                       #
-- #                                                                                     #
-- #######################################################################################
-- #######################################################################################


entity MAE is
    Port ( Clk         : in STD_LOGIC;
           Reset       : in STD_LOGIC;
           Fin_Tempo   : in STD_LOGIC;
           Fin_0       : in STD_LOGIC;
           Fin_1       : in STD_LOGIC;
           Reg_DCC     : in STD_LOGIC;
           Start_Tempo : out STD_LOGIC;
           Go_0        : out STD_LOGIC;
           Go_1        : out STD_LOGIC;
           Com_Reg     : out STD_LOGIC_VECTOR (1 downto 0));
           -- bit 1 : load, bit 0 : shift
end MAE;
-- J'ai dessinÃ© l'automate dans mon cahier de brouillon - Asmar
-- Faudrait qu'on se dÃ©cide comment le module REGISTRE_DCC fonctionne, sinon pas vraiment possible de complÃ©ter cet automate
architecture Behavioral of MAE is
-- Définition des Ã©tats :
type etat is(RES, START, LOAD, CHOICE, B0, B1, SHF);
signal EP, EF : etat;
signal cpt : STD_LOGIC_VECTOR (5 downto 0);
begin

    -- Process du registre d'Ã©tats
    process(clk, reset)
    begin
        if reset='1' then EP <= RES;
        elsif rising_edge(clk) then EP<=EF;
        end if;
    end process;
    
    -- Combinatoire des états
    process(EP, reg_dcc, Fin_Tempo, fin_0, fin_1, cpt)
    begin
        case(EP) is
            when RES    => EF<=START;
            -- Si l'attente est fini, la MAE demande le chargement de la prochaine trame, sinon elle attend
            when START  => EF<=START; if Fin_Tempo='1' then EF<=LOAD;  end if;
            -- Mode, Chargement de la trame à envoyer
            when LOAD   => EF<=CHOICE;  
            when CHOICE => EF<=B0;     if reg_dcc='1' then EF<=B1;    end if; 
            when B0     => EF<=B0;     if fin_0='1'   then EF<=SHF;   end if;
            when B1     => EF<=B1;     if fin_1='1'   then EF<=SHF;   end if;
            when SHF    => EF<=CHOICE; if cpt = 50    then EF<=START; end if; 
        end case;
    end process; 

    -- Combinatoire des sorties
    process(EP)
    begin
        -- ANTI-LATCH : On met tout Ã  0 par dÃ©faut !
        Start_Tempo <= '0';
        Go_0 <= '0';
        Go_1 <= '0';
        com_reg <= "00";
        case(EP) is
            when RES    => -- DÃ©jÃ  gÃ©rÃ© par l'anti-latch
            when START  => Start_Tempo <= '1';
            when LOAD   => com_reg <= "10";
            when CHOICE =>
            when B0     => Go_0 <= '1';
            when B1     => Go_1 <= '1';
            when SHF    => com_reg <= "01"; 
        end case;
    end process;
    
        -- Compteur 1MHz
    process(clk, reset)
    begin
        if reset='1' then cpt <= (others => '0');
        elsif rising_edge(clk) then
            if (EP = SHF) then
                if cpt = 50 then
                    cpt <= (others => '0');
                else
                    cpt <= cpt + 1;
                end if;
            else
               cpt <= cpt;
            end if;
        end if; 
    end process;
end Behavioral;
