----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: J.DENOULET, Winter 2021
--
-- Module Name: DCC_FRAME_GENERATOR - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: NEXYS 4 DDR
-- 
--	GÃ©nÃ©rateur de Trames de Test pour la Centrale DCC
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- ###################################################################################
-- ###################################################################################
-- #      Module qui crée une Trame DCC en fonction de l'interrupteur actionné       #
-- #                                                                                 #
-- # Interrupteur : Les entrées, interrupteurs de la carte                           #
-- # Trame_DCC    : Trame de sortie en fonction de l'interrupteur actionné           #
-- #                                                                                 #
-- ###################################################################################
-- ###################################################################################


entity DCC_FRAME_GENERATOR is
    Port ( Interrupteur	: in  STD_LOGIC_VECTOR( 7 downto 0);	-- Interrupteurs de la Carte
           addr_train   : in  STD_LOGIC_VECTOR( 7 downto 0);
           Trame_DCC 	: out STD_LOGIC_VECTOR(50 downto 0));	-- Trame DCC de Test (ordre hiérarchique)					
end DCC_FRAME_GENERATOR;

architecture Behavioral of DCC_FRAME_GENERATOR is

begin

-- Génération d'une Trame selon l'Interrupteur Tiré vers le Haut
-- Si Plusieurs Interupteurs Sont Tirés, Celui de Gauche Est Prioritaire

-- Compléter les Trames pour Réaliser les Tests Voulus

process(Interrupteur)
begin
	
	-- Interrupteur 7 Activé
		--> Trame Marche Avant du Train d'Adresse i
	if Interrupteur(7)='1' then
	
		Trame_DCC <=  b"11111111111111111111111"		     -- Préambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"01111111"			     -- Champ Commande vitesse Step 28
					& '0' 				         -- Start Bit
					& (addr_train xor b"01111111") -- Champ Contrôle
					& '1' 	;			         -- Stop Bit

	-- Interrupteur 6 ActivÃ©
		--> Trame Marche ArriÃ¨re du Train d'Adresse i
	elsif Interrupteur(6)='1' then
	
		Trame_DCC <=  b"11111111111111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"01000010"			     -- Champ Commande vitesse Step 1
					& '0' 				         -- Start Bit
					& (addr_train xor b"01000010") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit


	-- Interrupteur 5 ActivÃ©
		--> Allumage des Phares du Train d'Adresse i
	elsif Interrupteur(5)='1' then
	
		Trame_DCC <=  b"11111111111111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"10010000"			     -- Champ Commande
					& '0' 				         -- Start Bit
					& (addr_train xor b"10010000") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit

	-- Interrupteur 4 ActivÃ©
		--> Extinction des Phares du Train d'Adresse i
	elsif Interrupteur(4)='1' then
	
		Trame_DCC <=  b"11111111111111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"10000000"			     -- Champ Commande
					& '0' 				         -- Start Bit
					& (addr_train xor b"10000000") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit

	-- Interrupteur 3 ActivÃ©
		--> Activation du Klaxon (Fonction F11) du Train d'Adresse i
	elsif Interrupteur(3)='1' then
	
		Trame_DCC <=  b"11111111111111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"10100100"			     -- Champ Commande
					& '0' 				         -- Start Bit
					& (addr_train xor b"10100100") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit

	-- Interrupteur 2 ActivÃ©
		--> RÃ©amorÃ§age du Klaxon (Fonction F11) du Train d'Adresse i
	elsif Interrupteur(2)='1' then
	
		Trame_DCC <=  b"11111111111111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"10100000"			     -- Champ Commande
					& '0' 				         -- Start Bit
					& (addr_train xor b"10100000") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit

	-- Interrupteur 1 ActivÃ©
		--> Annonce SNCF (Fonction F13) du Train d'Adresse i
	elsif Interrupteur(1)='1' then
	
		Trame_DCC <=  b"11111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"11011110"		         -- Champ Commande 1
					& '0'
					& b"00000001"		         -- Champ Commande 2
					& '0' 				         -- Start Bit
					& ((addr_train xor b"11011110")
					               xor b"00000001") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit

	-- Interrupteur 0 ActivÃ©
		--> Annonce SNCF (Fonction F13) du Train d'Adresse i
	elsif Interrupteur(0)='1' then
	
		Trame_DCC <=  b"11111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"11011110"		         -- Champ Commande 1
					& '0'
					& b"00000000"		         -- Champ Commande 2
					& '0' 				         -- Start Bit
					& ((addr_train xor b"11011110")
					               xor b"00000000") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit

	-- Aucun Interrupteur ActivÃ©
		--> ArrÃªt du Train d'Adresse i
	else 
	
		Trame_DCC <=  b"11111111111111111111111"		     -- PrÃ©ambule
					& '0' 				         -- Start Bit
					& addr_train			     -- Champ Adresse
					& '0' 				         -- Start Bit
					& b"01100000"			     -- Champ Commande
					& '0' 				         -- Start Bit
					& (addr_train xor b"01100000") -- Champ ContrÃ´le
					& '1' 	;			         -- Stop Bit
	end if;
end process;

end Behavioral;

