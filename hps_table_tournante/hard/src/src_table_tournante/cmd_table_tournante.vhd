------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : cmd_table_tournante.vhd
-- Author               : Anthony Convers
-- Date                 : 04.12.2023
--
-- Context              : Commande table tournante
--
------------------------------------------------------------------------------------------
-- Description : 
--   
------------------------------------------------------------------------------------------
-- Dependencies : 
--   
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer    Comments
-- 0.0    See header              Initial version

------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
entity cmd_table_tournante is
  port(
    clock_i             : in  std_logic;
    reset_i             : in  std_logic;
    capt_a_i            : in  std_logic;
    capt_b_i            : in  std_logic;
    dir_pap_i           : in  std_logic;
    enable_pap_i        : in  std_logic;
    top_pap_i           : in  std_logic;
    inc_pos_o           : out std_logic;
    dec_pos_o           : out std_logic;
    ph_pap_o            : out std_logic_vector(1 downto 0);
    ph_error_o          : out std_logic
  );
end cmd_table_tournante;

architecture rtl of cmd_table_tournante is

    --| Components declaration |--------------------------------------------------------------
    
    -- Commande moteur pas-a-pas
    component cmd_mot_pap is
        port (
            clock_i      : in  std_logic;
            reset_i      : in  std_logic;
            top_signal_i : in  std_logic;
            dir_pap_i    : in  std_logic;
            enable_i     : in  std_logic;
            PH_A_o       : out std_logic;
            PH_B_o       : out std_logic
        );
    end component;
    
    -- protection des moteurs pas-a-pas
    component pap_watchdog is
        port (
            reset_i        : in  std_logic;
            clock_i        : in  std_logic;
            ph_i           : in  std_logic_vector(1 downto 0);
            ph_o           : out std_logic_vector(1 downto 0);
            ph_error_o     : out std_logic
        );
    end component pap_watchdog;
    
    -- Détecteur de rotation
    component mss_rot_det is
        port(reset_i  : in  std_logic;
            clk_i    : in  std_logic;
            a_i      : in  std_logic;
            b_i      : in  std_logic;
            err_o    : out std_logic;
            dir_cw_o : out std_logic; --modif EMI 2017 janvier
            cw_o     : out std_logic; -- decr pos cpt
            ccw_o    : out std_logic  -- incr pos cpt
    );
    end component;
    
    --| Constants declarations |--------------------------------------------------------------
    --| Signals declarations   |--------------------------------------------------------------   
    signal capt_a_sync_s : std_logic;
    signal capt_b_sync_s : std_logic;
    signal det_err_s : std_logic;
    signal dir_cw_s : std_logic;
    signal inc_pos_s : std_logic;
    signal dec_pos_s : std_logic;
    signal ph_error_s : std_logic;
    signal ph_pap_cmd_s : std_logic_vector(1 downto 0);
    signal ph_pap_filtered_s : std_logic_vector(1 downto 0);


begin
    
    -- Input signals
    
    -- Output signals
    inc_pos_o <= inc_pos_s;
    dec_pos_o <= dec_pos_s;
    ph_pap_o <= ph_pap_filtered_s;
    ph_error_o <= ph_error_s;
    
    
    -- Sychronisation des entrées de l'encodeur
    input_synchro_proc : process(clock_i, reset_i)
    begin
        if reset_i = '1' then
            capt_a_sync_s       <= '0';
            capt_b_sync_s       <= '0';
        elsif rising_edge(clock_i) then
            capt_a_sync_s       <= capt_a_i;
            capt_b_sync_s       <= capt_b_i;
        end if ;
    end process ;

    -----------------------------------------------------------
    ------------------ Détecteur de rotation ------------------
    -----------------------------------------------------------
    mss_rot_det_inst : mss_rot_det
    port map(
        reset_i     => reset_i,
        clk_i       => clock_i,
        a_i         => capt_a_sync_s,
        b_i         => capt_b_sync_s,
        err_o       => det_err_s,
        dir_cw_o    => dir_cw_s,
        cw_o        => inc_pos_s,
        ccw_o       => dec_pos_s
    );
    
    
    -----------------------------------------------------------
    ---------------- Commande moteur pas-a-pas ----------------
    -----------------------------------------------------------
    cmd_mot_pap_inst : cmd_mot_pap
    port map(
        clock_i      => clock_i,
        reset_i      => reset_i,
        top_signal_i => top_pap_i,
        dir_pap_i    => dir_pap_i,
        enable_i     => enable_pap_i,
        PH_A_o       => ph_pap_cmd_s(0),
        PH_B_o       => ph_pap_cmd_s(1)  
    );

    -----------------------------------------------------------
    ---------------- Protection moteur pas-a-pas --------------
    -----------------------------------------------------------
    pap_watchdog_inst : component pap_watchdog
    port map(
        reset_i        => reset_i,
        clock_i        => clock_i,
        ph_i           => ph_pap_cmd_s,
        ph_o           => ph_pap_filtered_s,
        ph_error_o     => ph_error_s
    );
    

    
end rtl; 