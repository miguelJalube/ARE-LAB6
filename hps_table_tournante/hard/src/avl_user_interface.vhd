------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : avl_user_interface.vhd
-- Author               : Bastien Pillonel & Miguel Jalube
-- Date                 : 28.01.2023
--
-- Context              : Avalon user interface
--
------------------------------------------------------------------------------------------
-- Description : 
--   User interface for turning table
------------------------------------------------------------------------------------------
-- Dependencies : 
--   top_gen.vhd, ilog_pkg.vhd
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer    Comments
-- 0.0    See header              Initial version

------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avl_user_interface is
  port (
    -- Avalon bus
    avl_clk_i           : in std_logic;
    avl_reset_i         : in std_logic;
    avl_address_i       : in std_logic_vector(13 downto 0);
    avl_byteenable_i    : in std_logic_vector(3 downto 0);
    avl_write_i         : in std_logic;
    avl_writedata_i     : in std_logic_vector(31 downto 0);
    avl_read_i          : in std_logic;
    avl_readdatavalid_o : out std_logic;
    avl_readdata_o      : out std_logic_vector(31 downto 0);
    avl_waitrequest_o   : out std_logic;
    avl_irq_o           : out std_logic;
    -- User interface
    boutton_i           : in std_logic_vector(3 downto 0);
    switch_i            : in std_logic_vector(9 downto 0);
    led_o               : out std_logic_vector(7 downto 0);
    hex0_o              : out std_logic_vector(6 downto 0);
    hex1_o              : out std_logic_vector(6 downto 0);
    hex2_o              : out std_logic_vector(6 downto 0);
    hex3_o              : out std_logic_vector(6 downto 0);
    hex4_o              : out std_logic_vector(6 downto 0);
    hex5_o              : out std_logic_vector(6 downto 0);
    -- table tournante
    t_idx_i             : in std_logic;
    t_capt_sup_i        : in std_logic;
    t_inc_pos_i         : in std_logic;
    t_dec_pos_i         : in std_logic;
    t_position_o        : out std_logic_vector(15 downto 0);
    t_dir_pap_o         : out std_logic;
    t_enable_pap_o      : out std_logic;
    t_top_pap_o         : out std_logic
  );
end avl_user_interface;

architecture rtl of avl_user_interface is

  --| Components declaration |--------------------------------------------------------------
  component top_gen is
    generic (
      PERIOD : integer range 1 to 1073741824 -- Limit counter size to 30 bits
    );
    port (
      --Sync
      clock_i : in std_logic;
      reset_i : in std_logic;
      --Inputs
      en_i    : in std_logic;
      --Outputs
      top_o   : out std_logic
    );
  end component top_gen;
  for all : top_gen use entity work.top_gen(calc);

  --| Constants declarations |--------------------------------------------------------------
  type cal_state_t is (
    WAITING,
    CAPT_SUP,
    IDX,
    GET_INIT_POS,
    WAIT_FOR_CAL_STOP
  );

  type req_mov_state_t is (
    WAITING,
    COUNT_MOVE
  );

  type irq_state_t is (
    NO_IRQ,
    IRQ_MIN,
    IRQ_MAX,
    GET_OUT_MIN,
    GET_OUT_MAX,
    WAIT_END
  );

  constant AVL_BUS_PERIOD                          : integer                                := 20;       -- 50MHz => 20ns
  constant TOP_BASE_PERIOD                         : integer                                := 10000000; -- 10ms

  constant INTERFACE_ID                            : std_logic_vector(avl_readdata_o'range) := x"DEADBEEF";
  constant READ_NOT_USED                           : std_logic_vector(avl_readdata_o'range) := x"DDEEAADD";
  constant POS_MIN                                 : unsigned(15 downto 0)                  := to_unsigned(2500, 16);
  constant POS_MAX                                 : unsigned(15 downto 0)                  := to_unsigned(62500, 16);
  constant POS_MID                                 : unsigned(15 downto 0)                  := to_unsigned(35000, 16);

  --| Signals declarations   |--------------------------------------------------------------   
  --| Top signal   |
  signal top_10ms_s                                : std_logic;
  signal top_cpt_pres_s, top_cpt_fut_s             : unsigned(3 downto 0);
  signal freq_div_s                                : unsigned(3 downto 0);
  signal top_pap_s                                 : std_logic;
  signal speed_s                                   : std_logic_vector(1 downto 0);
  --| Avalon signal   |
  signal avl_readdata_s                            : std_logic_vector(avl_readdata_o'range);
  signal avl_readdatavalid_s                       : std_logic;
  signal addr_int_s                                : integer := 0;
  --| I/Os   |
  signal led_s                                     : std_logic_vector(led_o'range);
  signal hex0_s                                    : std_logic_vector(hex0_o'range);
  signal hex1_s                                    : std_logic_vector(hex1_o'range);
  signal hex2_s                                    : std_logic_vector(hex2_o'range);
  signal hex3_s                                    : std_logic_vector(hex3_o'range);
  signal hex4_s                                    : std_logic_vector(hex4_o'range);
  signal hex5_s                                    : std_logic_vector(hex5_o'range);
  --| Turn table part   |
  signal reg_pos_pres_s, reg_pos_fut_s             : unsigned(15 downto 0);
  signal dir_s                                     : std_logic;
  signal en_pap_from_hps_s                         : std_logic;
  signal run_cal_init_s                            : std_logic;
  signal cal_init_busy_s                           : std_logic;
  signal cur_state_cal_s, fut_state_cal_s          : cal_state_t;
  signal pos_from_hps_s                            : unsigned(15 downto 0);
  signal pos_end_s                                 : unsigned(15 downto 0);
  signal move_busy_s                               : std_logic;
  signal run_move_s                                : std_logic;
  signal end_move_s                                : std_logic;
  signal cur_state_req_move_s, fut_state_req_mov_s : req_mov_state_t;
  signal cur_state_irq_s, fut_state_irq_s          : irq_state_t;
  signal avl_irq_s                                 : std_logic;
  signal lim_min_s, lim_max_s                      : std_logic;
  signal ack_s                                     : std_logic;
  signal get_out_s                                 : std_logic;
  signal mask_irq_s                                : std_logic;

begin

  -- Top 10ms instanciation
  gen_top_10ms : top_gen
  generic map(
    PERIOD => TOP_BASE_PERIOD / AVL_BUS_PERIOD
  )
  port map(
    en_i    => '1',
    top_o   => top_10ms_s,
    clock_i => avl_clk_i,
    reset_i => avl_reset_i
  );

  -- Top frequency divider -----------------------------------------------------------------------------------------------------
  -- Count n time 10ms (divide frequency depending on speed)
  freq_div_s    <= to_unsigned(10 - 1, freq_div_s'length) when speed_s = "00" else to_unsigned(4 - 1, freq_div_s'length) when speed_s = "01" else to_unsigned(2 - 1, freq_div_s'length) when speed_s = "10" else to_unsigned(1 - 1, freq_div_s'length) when speed_s = "11";
  top_cpt_fut_s <= top_cpt_pres_s when top_10ms_s = '0' else top_cpt_pres_s - 1 when top_cpt_pres_s /= 0 else freq_div_s;

  process (avl_reset_i, avl_clk_i)
  begin
    if avl_reset_i = '1' then
      top_cpt_pres_s <= freq_div_s;
    elsif rising_edge(avl_clk_i) then
      top_cpt_pres_s <= top_cpt_fut_s;
    end if;
  end process;

  top_pap_s     <= '1' when top_cpt_pres_s = 0 and top_10ms_s = '1' else '0';
  -------------------------------------------------------------------------------------------------------------------------------

  -- Futur state decoder of position register -----------------------------------------------------------------------------------
  reg_pos_fut_s <= reg_pos_pres_s + 1 when t_inc_pos_i = '1' else reg_pos_pres_s - 1 when t_dec_pos_i = '1' else reg_pos_pres_s;
  -------------------------------------------------------------------------------------------------------------------------------

  -- Read access part -----------------------------------------------------------------------------------------------------------
  addr_int_s    <= to_integer(unsigned(avl_address_i));

  read_channel : process (avl_clk_i, avl_reset_i)
  begin
    if avl_reset_i = '1' then
      avl_readdata_s      <= (others => '0');
      avl_readdatavalid_s <= '0';

    elsif rising_edge(avl_clk_i) then
      -- Delay by 1 clock cycle the avl_read_i signal for valid data signal
      avl_readdatavalid_s <= avl_read_i;

      -- By default read is set to 0 and later affected to correct data if read operation is requested
      avl_readdata_s      <= (others => '0');

      if avl_read_i = '1' then
        case addr_int_s is
          when 0      => avl_readdata_s(INTERFACE_ID'range)                                                   <= INTERFACE_ID;

          when 1      => avl_readdata_s(boutton_i'range)                                                      <= boutton_i;

          when 2      => avl_readdata_s(switch_i'range)                                                       <= switch_i;

          when 3      => avl_readdata_s(led_s'range)                                                          <= led_s;

          when 4      => avl_readdata_s(hex3_o'high + hex2_o'length + hex1_o'length + hex0_o'length downto 0) <= hex3_s & hex2_s & hex1_s & hex0_s;

          when 5      => avl_readdata_s(hex5_o'high + hex4_o'length downto 0)                                 <= hex5_s & hex4_s;

          when 6      => avl_readdata_s(reg_pos_pres_s'range)                                                 <= std_logic_vector(reg_pos_pres_s);

          when 7      => avl_readdata_s(3 downto 0)                                                           <= speed_s & dir_s & en_pap_from_hps_s;

          when 8      => avl_readdata_s(0)                                                                    <= cal_init_busy_s;

          when 9      => avl_readdata_s(15 downto 0)                                                          <= std_logic_vector(pos_end_s);

          when 10     => avl_readdata_s(0)                                                                   <= move_busy_s;

          when 11     => avl_readdata_s(1 downto 0)                                                          <= lim_max_s & lim_min_s;

          when others => avl_readdata_s                                                                  <= READ_NOT_USED;
        end case;
      end if;
    end if;
  end process read_channel;
  -------------------------------------------------------------------------------------------------------------------------------

  -- Write access part ----------------------------------------------------------------------------------------------------------
  write_channel : process (avl_clk_i, avl_reset_i)
  begin
    if avl_reset_i = '1' then
      led_s             <= (others => '0');
      hex0_s            <= (others => '0');
      hex1_s            <= (others => '0');
      hex2_s            <= (others => '0');
      hex3_s            <= (others => '0');
      hex4_s            <= (others => '0');
      hex5_s            <= (others => '0');
      speed_s           <= "00";
      dir_s             <= '0';
      en_pap_from_hps_s <= '0';
      run_cal_init_s    <= '0';
      pos_end_s         <= (others => '0');
      run_move_s        <= '0';
      ack_s             <= '0';
      mask_irq_s        <= '0';

      reg_pos_pres_s    <= POS_MID;

    elsif rising_edge(avl_clk_i) then
      if avl_write_i = '1' then
        case addr_int_s is
          when 3 => led_s          <= avl_writedata_i(led_s'range);

          when 4 => hex0_s         <= avl_writedata_i(hex0_s'range);
            hex1_s                   <= avl_writedata_i(hex1_s'high + hex0_s'length downto hex0_s'length);
            hex2_s                   <= avl_writedata_i(hex2_s'high + hex1_s'length + hex0_s'length downto hex1_s'length + hex0_s'length);
            hex3_s                   <= avl_writedata_i(hex3_s'high + hex2_s'length + hex1_s'length + hex0_s'length downto hex2_s'length + hex1_s'length + hex0_s'length);

          when 5 => hex4_s         <= avl_writedata_i(hex4_s'range);
            hex5_s                   <= avl_writedata_i(hex5_s'high + hex4_s'length downto hex4_s'length);

          when 6 => reg_pos_pres_s <= unsigned(avl_writedata_i(pos_from_hps_s'range));

          when 7 => speed_s        <= avl_writedata_i(3 downto 2);
            dir_s                    <= avl_writedata_i(1);
            en_pap_from_hps_s        <= avl_writedata_i(0);

          when 8  => run_cal_init_s <= avl_writedata_i(0);

          when 9  => pos_end_s      <= unsigned(avl_writedata_i(15 downto 0));

          when 10 => run_move_s    <= avl_writedata_i(0);

          when 11 => ack_s         <= avl_writedata_i(0);
            mask_irq_s               <= avl_writedata_i(1);

          when others => null;
        end case;

      else reg_pos_pres_s <= reg_pos_fut_s;
      end if;
    end if;
  end process write_channel;
  -------------------------------------------------------------------------------------------------------------------------------

  -- Turn table sync part for mss------------------------------------------------------------------------------------------------
  sync : process (avl_clk_i, avl_reset_i)
  begin
    if avl_reset_i = '1' then
      cur_state_cal_s      <= WAITING;

      cur_state_req_move_s <= WAITING;

      cur_state_irq_s      <= NO_IRQ;

    elsif rising_edge(avl_clk_i) then
      cur_state_cal_s      <= fut_state_cal_s;

      cur_state_req_move_s <= fut_state_req_mov_s;

      cur_state_irq_s      <= fut_state_irq_s;
    end if;
  end process;
  -------------------------------------------------------------------------------------------------------------------------------

  -- MSS for calibration and init part ------------------------------------------------------------------------------------------
  cal_mss : process (cur_state_cal_s, run_cal_init_s, t_capt_sup_i, t_idx_i, end_move_s)
  begin
    -- Default value
    cal_init_busy_s <= '0';
    fut_state_cal_s <= WAITING;

    case cur_state_cal_s is
      when WAITING =>
        cal_init_busy_s <= '0';
        if run_cal_init_s = '1' then
          fut_state_cal_s <= CAPT_SUP;
        end if;

      when CAPT_SUP =>
        cal_init_busy_s <= '1';
        if t_capt_sup_i = '1' then
          fut_state_cal_s      <= IDX;
        else fut_state_cal_s <= CAPT_SUP;
        end if;

      when IDX =>
        cal_init_busy_s <= '1';
        if t_idx_i = '1' then
          fut_state_cal_s      <= GET_INIT_POS;
        else fut_state_cal_s <= IDX;
        end if;

      when GET_INIT_POS =>
        cal_init_busy_s <= '1';
        fut_state_cal_s <= WAIT_FOR_CAL_STOP;

      when WAIT_FOR_CAL_STOP =>
        if run_cal_init_s = '0' then
          fut_state_cal_s      <= WAITING;
        else fut_state_cal_s <= WAIT_FOR_CAL_STOP;
        end if;

      when others =>
        fut_state_cal_s <= WAITING;

    end case;
  end process cal_mss;
  -------------------------------------------------------------------------------------------------------------------------------

  -- Req mov decounter fut decoder ----------------------------------------------------------------------------------------------
  end_move_s <= '1' when reg_pos_pres_s = pos_end_s else '0';
  -------------------------------------------------------------------------------------------------------------------------------

  -- MSS for requested movement -------------------------------------------------------------------------------------------------
  req_mov_mss : process (cur_state_req_move_s, run_move_s, end_move_s)
  begin
    -- Default value
    move_busy_s         <= '0';
    fut_state_req_mov_s <= WAITING;

    case cur_state_req_move_s is
      when WAITING =>
        if run_move_s = '1' then
          fut_state_req_mov_s      <= COUNT_MOVE;
        else fut_state_req_mov_s <= WAITING;
        end if;

      when COUNT_MOVE =>
        move_busy_s <= '1';
        if end_move_s = '1' then
          fut_state_req_mov_s      <= WAITING;
        else fut_state_req_mov_s <= COUNT_MOVE;
        end if;

      when others =>
        fut_state_req_mov_s <= WAITING;

    end case;

  end process req_mov_mss;
  -------------------------------------------------------------------------------------------------------------------------------

  -- Interface for irq mss ------------------------------------------------------------------------------------------------------
  lim_min_s <= '1' when reg_pos_pres_s <= POS_MIN else '0';
  lim_max_s <= '1' when reg_pos_pres_s >= POS_MAX else '0';
  -------------------------------------------------------------------------------------------------------------------------------

  -- MSS for irq handling -------------------------------------------------------------------------------------------------------
  irq_mss : process (cur_state_irq_s, lim_min_s, lim_max_s, ack_s, move_busy_s, dir_s)
  begin
    -- default value
    avl_irq_s       <= '0';
    get_out_s       <= '0';

    fut_state_irq_s <= NO_IRQ;

    case cur_state_irq_s is
      when NO_IRQ =>
        if lim_min_s = '1' then
          fut_state_irq_s <= IRQ_MIN;
        elsif lim_max_s = '1' then
          fut_state_irq_s      <= IRQ_MAX;
        else fut_state_irq_s <= NO_IRQ;
        end if;

      when IRQ_MIN =>
        avl_irq_s <= '1';
        if ack_s = '1' then
          fut_state_irq_s      <= GET_OUT_MIN;
        else fut_state_irq_s <= IRQ_MIN;
        end if;

      when GET_OUT_MIN =>
        get_out_s <= '1';
        if move_busy_s = '1' and dir_s = '0' then
          fut_state_irq_s      <= WAIT_END;
        else fut_state_irq_s <= GET_OUT_MIN;
        end if;

      when IRQ_MAX =>
        avl_irq_s <= '1';
        if ack_s = '1' then
          fut_state_irq_s      <= GET_OUT_MAX;
        else fut_state_irq_s <= IRQ_MAX;
        end if;

      when GET_OUT_MAX =>
        get_out_s <= '1';
        if move_busy_s = '1' and dir_s = '1' then
          fut_state_irq_s      <= WAIT_END;
        else fut_state_irq_s <= GET_OUT_MAX;
        end if;

      when WAIT_END =>
        if move_busy_s = '0' then
          fut_state_irq_s      <= NO_IRQ;
        else fut_state_irq_s <= WAIT_END;
        end if;

      when others => fut_state_irq_s <= NO_IRQ;
    end case;

  end process irq_mss;
  -------------------------------------------------------------------------------------------------------------------------------

  -- Interface management
  -- I/O
  led_o               <= led_s;
  hex0_o              <= hex0_s;
  hex1_o              <= hex1_s;
  hex2_o              <= hex2_s;
  hex3_o              <= hex3_s;
  hex4_o              <= hex4_s;
  hex5_o              <= hex5_s;
  -- Avalon
  avl_readdata_o      <= avl_readdata_s;
  avl_readdatavalid_o <= avl_readdatavalid_s;
  avl_irq_o           <= '0' when mask_irq_s = '1' else avl_irq_s;
  -- Turnnig table
  t_position_o        <= std_logic_vector(reg_pos_pres_s);
  t_dir_pap_o         <= dir_s;
  t_enable_pap_o      <= '0' when avl_irq_s = '1' else '1' when cal_init_busy_s = '1' or move_busy_s = '1' or get_out_s = '1' else en_pap_from_hps_s;
  t_top_pap_o         <= top_pap_s;
  -- Unused
  avl_waitrequest_o   <= '0';

end rtl;