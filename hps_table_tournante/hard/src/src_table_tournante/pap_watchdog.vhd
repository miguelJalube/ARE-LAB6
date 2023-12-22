-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : pap_watchdog.vhd
--
-- Description  : Protection contre un une vitesse trop élevée du driver mot pap
--                
-- Auteur       : Peter Podolec
-- Date         : 20.05.2022
-- Version      : 1.0
--
--
--| Modifications |-------------------------------------------------------------
--  Ver     Auteur      Date        Description
--  1.0     20.05.2022  PPC         Version initiale
--                          
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity pap_watchdog is
    port (
        reset_i        : in  std_logic;
        clock_i        : in  std_logic;
        ph_i           : in  std_logic_vector(1 downto 0);
        ph_o           : out std_logic_vector(1 downto 0);
        ph_error_o     : out std_logic
    );
end pap_watchdog;

architecture behav of pap_watchdog is

    -- signaux du compteur
    signal cpt_pres_s    : unsigned(23 downto 0);
    signal cpt_fut_s     : unsigned(23 downto 0);
    
    -- nombre de coups d'horloge sans transition de phase à respecter
    -- ACS ajout de -41 à la limite pour test avec de1soc
    constant LIMIT : unsigned := to_unsigned(500000 - 5, cpt_pres_s'length);

    signal ph_reg_s     : std_logic_vector(ph_i'high downto 0);
    signal pas_pap_s    : std_logic;    -- indique une transition dans les phases => un pas

begin

    -- compteur
    cpt_proc : process(reset_i, clock_i)
    begin
        if reset_i = '1' then
            cpt_pres_s <= (others => '0');
        elsif rising_edge(clock_i) then
            cpt_pres_s <= cpt_fut_s;
        end if ;
    end process;
    
    cpt_fut_s <= LIMIT when pas_pap_s = '1' else
                cpt_pres_s - 1 when cpt_pres_s /= 0 else
                (others => '0');
    
    -- bascules de mémorisation des entrées pour la détection de flanc
    ph_reg : process(reset_i, clock_i)
    begin
        if reset_i = '1' then
            ph_reg_s <= (others => '0');
        elsif rising_edge(clock_i) then
            ph_reg_s <= ph_i;
        end if ;
    end process;

    pas_pap_s <= '1' when unsigned(ph_reg_s) /= unsigned(ph_i) else '0';

    -- assignation des sorties de manière synchrone
    ph_out : process(reset_i, clock_i)
    begin
        if reset_i = '1' then
            ph_o <= (others => '0');
            ph_error_o <= '0';
        elsif rising_edge(clock_i) then
            if pas_pap_s = '1' then -- un pas est demandé
                if cpt_pres_s = 0 then
                    ph_o <= ph_i;
                else
                    ph_error_o <= '1'; -- l'indcateur d'erreur bascule à '1', sans jamais revenir à '0'
                end if;
            end if;
        end if ;
    end process;

end behav;