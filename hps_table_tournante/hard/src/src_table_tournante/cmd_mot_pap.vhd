-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : cmd_mot_pap.vhd
--
-- Description  : MSS pour faire tourner le moteur pas a pas. 
-- 
-- Auteur       : Steeve Werren 
-- Date         : 22.08.2011
-- Version      : 1.0
--
--
--| Modifications |-------------------------------------------------------------
--
-- Auteur       : Florent Duployer
-- Date         : 25.08.2011
-- Version      : 2.0
-- Description  : Ajout d'un interface pour que les MSS crees soient controlables
--                depuis une console Tcl/Tk de demonstration
-------------------------------------------------------------------------------
--
-- Auteur       : Flavio Capitao
-- Date         : 12.01.2017
-- Version      : 3.0
-- Description  : Enlevé detection de flanc montant du signal top car il fait 
--                  une pulse.
-------------------------------------------------------------------------------
--
-- Auteur       : Anthony Convers
-- Date         : 14.12.2023
-- Version      : 4.0
-- Description  : La FSM tourne dans l'autre sens lors d'un changement de direction  
--                  car l'inversion de phase peut faire bouger les moteurs et creer
--                  une erreur dans pap_watchdog
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity cmd_mot_pap is
    port (
    Clock_i      : in std_logic;
    Reset_i      : in std_logic;
    top_signal_i : in std_logic;
    dir_pap_i    : in std_logic; -- dir '0' => position incrémente
    Enable_i     : in std_logic;
    PH_A_o       : out std_logic;
    PH_B_o       : out std_logic
    );
end cmd_mot_pap;

architecture behav of cmd_mot_pap is
    -- MSS genere phases A et B
    type STATE_PHASE is (PH0, PH1, PH2, PH3);
    signal CS_PHASE, NS_PHASE : STATE_PHASE;
    signal PH1_s, PH2_s       : std_logic;
begin

    -- Machine d'etat
    Transistion_PHASE: process(CS_PHASE, Enable_i, top_signal_i) is --
    begin
        --valeur par defaut des sorties
        NS_PHASE <= PH0; -- etat inital
        PH1_s    <= '0';
        PH2_s    <= '0';
    
        case CS_PHASE is
            when PH0 =>
                PH1_s   <= '0';
                PH2_s   <= '0';
                
                if (Enable_i = '1') and (top_signal_i = '1') then
                    if dir_pap_i = '0' then
                        NS_PHASE <= PH1;
                    else
                        NS_PHASE <= PH3;
                    end if;
                else
                    NS_PHASE <= PH0;
                end if;
                
            when PH1 =>
                PH1_s   <= '1';
                PH2_s   <= '0';
                
                if (Enable_i = '1') and (top_signal_i = '1') then
                    if dir_pap_i = '0' then
                        NS_PHASE <= PH2;
                    else
                        NS_PHASE <= PH0;
                    end if;
                else
                    NS_PHASE <= PH1;
                end if;
                
            when PH2 =>
                PH1_s   <= '1';
                PH2_s   <= '1';
                
                if (Enable_i = '1') and (top_signal_i = '1') then
                    if dir_pap_i = '0' then
                        NS_PHASE <= PH3;
                    else
                        NS_PHASE <= PH1;
                    end if;
                else
                    NS_PHASE <= PH2;
                end if;
            
            when PH3 =>
                PH1_s   <= '0';
                PH2_s   <= '1';
                
                if (Enable_i = '1') and (top_signal_i = '1') then
                    if dir_pap_i = '0' then
                        NS_PHASE <= PH0;
                    else
                        NS_PHASE <= PH2;
                    end if;
                else
                    NS_PHASE <= PH3;
                end if;
            
            when others =>
                PH1_s   <= '0';
                PH2_s   <= '0';
                NS_PHASE <= PH0;
        end case;
    end process Transistion_PHASE;
  
  
    MSS_update: process(Clock_i, Reset_i) is
    begin
        if (Reset_i = '1') then
            CS_PHASE <= PH0;
        elsif rising_edge(Clock_i) then
            CS_PHASE <= NS_PHASE;
        end if;
    end process MSS_update;
    
    PH_A_o <= PH2_s;
    PH_B_o <= PH1_s;
  
end behav;