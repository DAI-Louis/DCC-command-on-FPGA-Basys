----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: J.DENOULET, Winter 2021
--
-- Module Name: COMPTEUR_TEMPO - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: NEXYS 4 DDR
-- 
--	Compteur de Temporisation de la Centrale DCC
--
--		Après détection du passage à 1 de la commande Start_Tempo,
--		le module compte 6 ms et positionne à 1 la sortie Fin_Tempo
--
--		Pour être détectée, la commande Start_Tempo doit être mise à 1
--		pendant au moins 1 période de l'horloge 100 MHz
--
--		Quand Fin_Tempo pase à 1, la sortie reste dans cet état tant que 
--		Start_Tempo est à 1. 
--		Dès la détection du retour à 0 de Start_Tempo,
--		Fin_Tempo repasse à 0.
--		
--		De cette manière, la durée de minimale l'impulsion à 1 de 
--		Fin_Tempo sera d'un cycle de l'horloge 100 MHz.
--		Cela est a priori suffisant pour sa bonne détection
--		par la MAE de la Centrale DCC.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COMPTEUR_TEMPO is
    Port ( Clk 			: in STD_LOGIC;		-- Horloge 100 MHz
           Reset 		: in STD_LOGIC;		-- Reset Asynchrone
           Clk1M 		: in STD_LOGIC;		-- Horloge 1 MHz
           Start_Tempo	: in STD_LOGIC;		-- Commande de Démarrage de la Temporisation
           Fin_Tempo	: out STD_LOGIC		-- Drapeau de Fin de la Temporisation
		);
end COMPTEUR_TEMPO;

architecture Behavioral of COMPTEUR_TEMPO is

signal Q: std_logic_vector(1 downto 0); -- Etat Séquenceur
signal Raz_CPt,Inc_Cpt: std_logic; -- Commandes Compteur
signal Fin_Cpt: std_logic; -- Drapeau de Fin de Comptage

-- Compteur de Temporisation
signal Cpt	    : INTEGER range 0 to 10000; -- Compteur (6000 = 6 ms)
signal En_Tempo	: STD_LOGIC;				-- Commande d'Incrémentation

begin

    -- Séquenceur
    process(Clk,Reset)
    begin
        if Reset='1' then Q <= "00";
        elsif rising_edge(Clk) then
            Q(1) <= ((not Q(1)) and Q(0) and Fin_Cpt) or (Q(1) and Start_Tempo);
            Q(0) <= Start_Tempo or ((not Q(1)) and Q(0));
        end if;
    end process;

    -- Sorties Séquenceur
    Raz_Cpt <= Q(1) xnor Q(0);
    Inc_Cpt <= (not Q(1)) and Q(0);
    Fin_Tempo <= Q(1) and Q(0);  


    -- Compteur de Temporisation
	process (Clk1M, Reset)
    begin
        -- Reset Asynchrone
        if (Reset) = '1' then
            Cpt <= 0;
        elsif rising_edge (Clk1M) then
            if Raz_Cpt = '1' then Cpt <= 0;
            elsif Inc_Cpt = '1' then Cpt <= Cpt  + 1;
            end if;
        end if;
    end process;

    Fin_Cpt <= '1' when (Cpt = 5999) else '0';

end Behavioral;
