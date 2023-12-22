-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mss_rot_det.vhd
--
-- Description  : MSS pour la gestion d'un encodeur rotatif
--
-- Auteur       : Loïc Haas
-- Date         : 09.01.2016
-- Version      : 1.0
--
-- Utilise      :
--
--| Modifications |------------------------------------------------------------
-- Ver   Auteur Date        Description
-- 1.0    LHS   09.01.2016  Première vesion de la MSS
-- 2.0    EMI   24.01.2017  Rajouter maintien de state_fut dans dec_fut
--                          pour supprimer generation latch sur ce signal
--                          Rajouter signal dir_cw_o dans la mss_rot_det
-- 2.1    YTA   20.08.2018  Correction d'une erreur liée à la détection d'une
--                          erreur sur les entrées. La ligne fausse (104) est
--                          commentée.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mss_rot_det is
   port(reset_i  : in  std_logic;
        clk_i    : in  std_logic;
        a_i      : in  std_logic;
        b_i      : in  std_logic;
        err_o    : out std_logic;
        dir_cw_o : out std_logic; --modif EMI 2017 janvier
        cw_o     : out std_logic;
        ccw_o    : out std_logic
   );
end mss_rot_det;

architecture struct of mss_rot_det is

    -- Declaration des etats

    -- 2 last bit are a and b input
    constant E_init_head  : std_logic_vector(5 downto 2) := "1000";
    constant E_init       : std_logic_vector(5 downto 0) := "100000";
    constant E_error_head : std_logic_vector(5 downto 2) := "1100";
    constant E_error      : std_logic_vector(5 downto 0) := "110000";

    constant E_cw_head  : std_logic_vector(5 downto 2) := "0001";
    constant E_cw_00    : std_logic_vector(5 downto 0) := E_cw_head & "00";
    constant E_cw_10    : std_logic_vector(5 downto 0) := E_cw_head & "10";
    constant E_cw_11    : std_logic_vector(5 downto 0) := E_cw_head & "11";
    constant E_cw_01    : std_logic_vector(5 downto 0) := E_cw_head & "01";

    constant E_ccw_head : std_logic_vector(5 downto 2) := "0010";
    constant E_ccw_00   : std_logic_vector(5 downto 0) := E_ccw_head & "00";
    constant E_ccw_10   : std_logic_vector(5 downto 0) := E_ccw_head & "10";
    constant E_ccw_11   : std_logic_vector(5 downto 0) := E_ccw_head & "11";
    constant E_ccw_01   : std_logic_vector(5 downto 0) := E_ccw_head & "01";

    constant E_sta_head : std_logic_vector(5 downto 2) := "0000";
    constant E_sta_00   : std_logic_vector(5 downto 0) := E_sta_head & "00";
    constant E_sta_10   : std_logic_vector(5 downto 0) := E_sta_head & "10";
    constant E_sta_11   : std_logic_vector(5 downto 0) := E_sta_head & "11";
    constant E_sta_01   : std_logic_vector(5 downto 0) := E_sta_head & "01";


    -- declaration internal signals
    signal state_cur, state_fut : std_logic_vector(5 downto 0);
    signal dir_cw_fut, dir_cw_pres : std_logic;  --modif EMI 2017 janvier
    signal a_s, b_s             : std_logic;
    signal cur_ab_s             : std_logic_vector(1 downto 0);

begin
    cur_ab_s <= a_s & b_s;

    a_s <= a_i;
    b_s <= b_i;

    StateFutP:
    process(all) is --state_cur, cur_ab_s, dir_cw_pres)
        variable state_cur_ab         : std_logic_vector(1 downto 0);
        variable state_cur_head       : std_logic_vector(5 downto 2);
    begin
        state_cur_ab    := state_cur(1 downto 0);
        state_cur_head  := state_cur(5 downto 2);

        dir_cw_fut <= dir_cw_pres; --valeur par defaut  EMI 2017 janvier

        case state_cur_head is

            when E_init_head | E_error_head =>
                state_fut <= E_sta_head & cur_ab_s; -- Correct stable state

            when E_cw_head | E_ccw_head | E_sta_head =>
                if (state_cur_ab = cur_ab_s) then
                     state_fut <= E_sta_head   & state_cur_ab;

--                 elsif (cur_ab_s(1) = (not state_cur_ab(0)) AND cur_ab_s(0) = (not state_cur_ab(1))) then
                elsif (cur_ab_s(0) = (not state_cur_ab(0)) AND cur_ab_s(1) = (not state_cur_ab(1))) then
                    state_fut <= E_error;

                elsif (state_cur_ab = "01" AND cur_ab_s = "00") then
                    state_fut <= E_cw_00;
                    dir_cw_fut <= '1'; --modif EMI 2017 janvier
                elsif (state_cur_ab = "11" AND cur_ab_s = "01") then
                    state_fut <= E_cw_01;
                    dir_cw_fut <= '1'; --modif EMI 2017 janvier
                elsif (state_cur_ab = "10" AND cur_ab_s = "11") then
                    state_fut <= E_cw_11;
                    dir_cw_fut <= '1'; --modif EMI 2017 janvier
                elsif (state_cur_ab = "00" AND cur_ab_s = "10") then
                    state_fut <= E_cw_10;
                    dir_cw_fut <= '1'; --modif EMI 2017 janvier

                elsif (state_cur_ab = "10" AND cur_ab_s = "00") then
                    state_fut <= E_ccw_00;
                    dir_cw_fut <= '0'; --modif EMI 2017 janvier
                elsif (state_cur_ab = "00" AND cur_ab_s = "01") then
                    state_fut <= E_ccw_01;
                    dir_cw_fut <= '0'; --modif EMI 2017 janvier
                elsif (state_cur_ab = "01" AND cur_ab_s = "11") then
                    state_fut <= E_ccw_11;
                    dir_cw_fut <= '0'; --modif EMI 2017 janvier
                elsif (state_cur_ab = "11" AND cur_ab_s = "10") then
                    state_fut <= E_ccw_10;
                    dir_cw_fut <= '0'; --modif EMI 2017 janvier
                else  -- modification EMI 2017 janvier
                    state_fut <= state_cur; --manque maintien etat present
                end if;
            when others =>
                state_fut <= E_error; --  default
        end case;
    end process;

    Mem:
    process (clk_i, reset_i)
    begin
        if (reset_i = '1') then
            state_cur   <= E_init;
            dir_cw_pres <= '0';  --modif EMI 2017 janvier
        elsif rising_edge(clk_i) then
            state_cur   <= state_fut;
            dir_cw_pres <= dir_cw_fut; --modif EMI 2017 janvier
        end if;
    end process;

    dir_cw_o <= dir_cw_pres;
    cw_o  <= state_cur(2);
    ccw_o <= state_cur(3);
    err_o <= state_cur(4);
end struct;
