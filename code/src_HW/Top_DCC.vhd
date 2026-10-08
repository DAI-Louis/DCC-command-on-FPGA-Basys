----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.04.2026 09:15:20
-- Design Name: 
-- Module Name: TOP_DCC - Behavioral
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

entity TOP_DCC is
    Port ( reset : in STD_LOGIC;
           sys_clock : in STD_LOGIC;
           sw_tri_i	: in STD_LOGIC_VECTOR(7 downto 0);
--           JB : out STD_LOGIC_VECTOR(10 downto 1));
           Sortie_DCC : out STD_LOGIC);
end TOP_DCC;

architecture Behavioral of TOP_DCC is

    signal Clk1M     : STD_LOGIC;

    -- 2. Signaux pour la gestion de la Temporisation
    signal Start_Tempo : STD_LOGIC;
    signal Fin_Tempo   : STD_LOGIC;

    -- 3. Signaux d'interconnexion (Les "câbles" entre la MAE et les autres blocs)
    signal Go_1, Fin_1 : STD_LOGIC;
    signal Go_0, Fin_0 : STD_LOGIC;
    
    signal Reg_DCC : STD_LOGIC;
    signal Com_Reg : STD_LOGIC_VECTOR(1 downto 0);
    
    -- 4. Signaux pour le registre et l'extérieur
    signal Trame_DCC : STD_LOGIC_VECTOR(50 downto 0);
    
    -- Sorties réelles du système
    signal DCC_0 : STD_LOGIC;
    signal DCC_1 : STD_LOGIC;

begin

    U_CLKDIV: entity work.CLK_DIV
    port map (
        Clk_IN      => sys_clock,
        Reset       => reset,
        Clk_Out     => Clk1M
    );
    
    U_GENERATOR: entity work.DCC_FRAME_GENERATOR
    port map (
        Interrupteur => sw_tri_i,
        Trame_DCC    => Trame_DCC
    );
    
    U_MAE: entity work.MAE
    port map (
        Clk         => sys_clock,
        Reset       => reset,
        Start_Tempo => Start_Tempo,
        Fin_Tempo   => Fin_Tempo,
        Go_1        => Go_1,
        Fin_1       => Fin_1,
        Go_0        => Go_0,
        Fin_0       => Fin_0,
        Reg_DCC     => Reg_DCC,
        Com_Reg     => Com_Reg
    );

    U_REGISTRE: entity work.REGISTRE_DCC
    port map (
        Clk       => sys_clock,
        reset     => reset,
        Trame_DCC => Trame_DCC,
        COM_REG   => Com_Reg,
        Reg_DCC   => Reg_DCC
    );
    
     U_TEMPO: entity work.COMPTEUR_TEMPO
    port map (
    Clk         => sys_clock,
    Reset       => reset,
    Clk1M       => Clk1M,
    Start_Tempo => Start_Tempo,
    Fin_Tempo   => Fin_Tempo
    );
    
    U_BIT0: entity work.DCC_BIT0
    port map (
        Clk1M => Clk1M,
        Clk   => sys_clock,
        Reset => reset,
        Go    => Go_0,
        Fin   => Fin_0,
        DCC   => DCC_0
    );

    U_BIT1: entity work.DCC_BIT1
    port map (
        Clk1M => Clk1M,
        Clk   => sys_clock,
        Reset => reset,
        Go    => Go_1,
        Fin   => Fin_1,
        DCC   => DCC_1
    );
    
--    JB <= ( 4 => (DCC_0 xor DCC_1), others => '0');
    Sortie_DCC <= DCC_0 or DCC_1;
end Behavioral;
