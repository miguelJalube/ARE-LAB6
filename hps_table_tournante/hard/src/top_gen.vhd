-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : top_gen.vhd
--
-- Description  : Génère un pulse d'un tick avec une période renseignée dans 
--                  le paramètre générique
-- Auteur       : Anthony I. Jaccard
-- Date         : 31.03.2023
-- Version      : 1.0
-- 
-- Utilise      : 
-- 
--| Modifications |------------------------------------------------------------
-- Vers.  Qui   Date         Description
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ilog_pkg.all;

entity top_gen is
    generic (
        PERIOD : integer range 1 to 1073741824 -- Limit counter size to 30 bits
    );
    port (
        --Sync
        clock_i     : in std_logic;
        reset_i     : in std_logic;
        --Inputs
        en_i  : in std_logic;
        --Outputs
        top_o   : out std_logic
    );
end entity top_gen;

architecture calc of top_gen is

    constant WORD_SIZE : integer := ilog(PERIOD) + 1; -- Calculate optimal register size

    signal cpt_pres_s, cpt_fut_s : unsigned(WORD_SIZE-1 downto 0);

begin

    cpt_fut_s <=    cpt_pres_s       when en_i = '0' else -- Hold 
                    cpt_pres_s - 1   when cpt_pres_s /= 0 else
                    To_Unsigned(PERIOD-1, WORD_SIZE);

    process (clock_i, reset_i)
    begin
        if reset_i = '1' then
            cpt_pres_s <= (others => '0');
        elsif rising_edge(clock_i) then
            cpt_pres_s <= cpt_fut_s;
        end if;
    end process;

    top_o <= '1' when cpt_pres_s = 0 and en_i = '1' else '0'; -- Pulse generation

end architecture;
