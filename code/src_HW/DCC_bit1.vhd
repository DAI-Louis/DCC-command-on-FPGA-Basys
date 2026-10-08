----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2026 11:53:42
-- Design Name: 
-- Module Name: DCC_bit1 - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ###################################################################################
-- #               Module qui envoie un bit 1 du protocole DCC                       #
-- #                                                                                 #
-- # Clk1M : L'horloge 1 MHz, pour le compteur                                       #
-- # Clk   : Horloge 100 MHz, pour tous les modules                                  #
-- # Reset : Signal de réinitialisation                                              #
-- # Go    : Signal d'activation du module (1 : activé, 0 : IDLE)                    #
-- # Fin   : Signal pour indiquer la fin   (1 : fin,    0 : pas fini)                #
-- # DCC   : Bit de sortie du 1 selon le protocole DCC (58 us en 0 puis 58 us en 1)  #
-- ###################################################################################

entity DCC_BIT1 is
    Port ( Clk1M : in STD_LOGIC;
           Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Go : in STD_LOGIC;
           Fin : out STD_LOGIC;
           DCC : out STD_LOGIC);
end DCC_BIT1;

architecture Behavioral of DCC_BIT1 is
-- On rajoute WAIT0 et WAIT1 pour synchroniser le lièvre et la tortue
type etat is(RES, IDLE, IM0, WAIT0, IM1, WAIT1, ENDST);
signal cpt : STD_LOGIC_VECTOR (7 downto 0);
signal EP, EF : etat;

begin
    
    -- Le registre d'état tourne bien sur l'horloge rapide (100 MHz)
    process(Clk, Reset)
        begin 
            if Reset='1' then EP <= RES;
            elsif rising_edge(Clk) then EP<=EF;
        end if;
    end process;
    
    -- Combinatoire des états
    process(EP, Go, cpt)
    begin
        case(EP) is
            when RES   => EF <= IDLE;
            when IDLE  => EF <= IDLE;  if Go='1'    then EF <= IM0;   end if;
            
            -- Phase du '0'
            when IM0   => EF <= IM0;   if cpt = 56  then EF <= WAIT0; end if;
            when WAIT0 => EF <= WAIT0; if cpt = 0   then EF <= IM1;   end if; -- On attend que le compteur retombe à 0
            
            -- Phase du '1'
            when IM1   => EF <= IM1;   if cpt = 56  then EF <= WAIT1; end if;
            when WAIT1 => EF <= WAIT1; if cpt = 0   then EF <= ENDST; end if; -- On attend que le compteur retombe à 0
            
            when ENDST => EF <= IDLE;
        end case;
    end process;
    
    -- Combinatoire des sorties
    process(EP)
    begin
        case(EP) is
            when RES   => Fin <= '0'; DCC <= '0'; 
            when IDLE  => Fin <= '0'; DCC <= '0'; 
            
            -- La sortie DCC reste à 0 pendant IM0 ET WAIT0
            when IM0   => Fin <= '0'; DCC <= '0';
            when WAIT0 => Fin <= '0'; DCC <= '0';
            
            -- La sortie DCC reste à 1 pendant IM1 ET WAIT1
            when IM1   => Fin <= '0'; DCC <= '1';
            when WAIT1 => Fin <= '0'; DCC <= '1';
            
            when ENDST => Fin <= '1'; DCC <= '0';
        end case;
    end process;
    
    -- Compteur sur horloge lente (1 MHz)
    process(Clk1M, Reset)
    begin
        if Reset='1' then 
            cpt <= (others => '0');
        elsif rising_edge(Clk1M) then
        
            -- Si la machine est à l'arrêt, le compteur reste à 0
            if (EP = RES) or (EP = IDLE) or (EP = ENDST) then
                cpt <= (others => '0');
            else
                -- Si la machine est active (IM0, WAIT0, IM1, WAIT1), on compte
                if cpt = 56 then
                    cpt <= (others => '0');
                else
                    cpt <= cpt + 1;
                end if;
            end if;
            
        end if; 
    end process;

end Behavioral;