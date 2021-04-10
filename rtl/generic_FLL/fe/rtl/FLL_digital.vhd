-------------------------------------------------------------------------------
-- Title      : digital section top
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLL_digital.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: top level of the digital section of the FLL
--
-------------------------------------------------------------------------------
-- Copyright 2018 ETH Zurich and University of Bologna.
-- Copyright and related rights are licensed under the Solderpad Hardware
-- License, Version 0.51 (the "License"); you may not use this file except in
-- compliance with the License.  You may obtain a copy of the License at
-- http:--solderpad.org/licenses/SHL-0.51. Unless required by applicable law
-- or agreed to in writing, software, hardware and materials distributed under
-- this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
-- CONDITIONS OF ANY KIND, either express or implied. See the License for the
-- specific language governing permissions and limitations under the License.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author              Description
-- 2016-10-18  3.0      bellasid            ported to tsmc55lp
-- 2017-01-27  3.1      muheim              change it to tech independens
--                                          replace clock gated (POSTICG_X4B_A9TL) by a entity FLL_clock_gated
--                                          replace the mux (MX2_X4B_A9TR) by a behavioral description
-- 2017-06-12  3.2      bellasid            change the control of the int reg enable
--                                          signal to solve unwanted int reg updates
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FLLPkg.all;

entity FLL_digital is
  port(
    --
    -- to/from DCO clock domain
    DITH     : out std_logic;           -- dithering pattern
    DITHB    : out std_logic;           -- dithering pattern inverted
    DCOCLK   : in  std_logic;           -- DCO clock in
    --
    FLLCLK   : out std_logic;           -- FLL clock out
    --
    -- to/from ref clock domain
    DCOD     : out std_logic_vector(9 downto 0);  -- DCO digital control word
    DCODB    : out std_logic_vector(9 downto 0);  -- DCO digital control word inverted
    DCOENB   : out std_logic;           -- DCO enable
    DCOPWD   : out std_logic;           -- DCO power down (active low)
    DCORET   : out std_logic;           -- DCO retention  (active low)
    REFCLK   : in  std_logic;           -- reference clock input
    --
    -- to/from SoC clock domain
    FLLOE    : in  std_logic;  -- FLL clock output enable (active high)
    LOCK     : out std_logic;           -- FLL lock signal (active high)
    CFGREQ   : in  std_logic;           -- configuration port handshake
    CFGACK   : out std_logic;           -- configuration port handshake
    CFGAD    : in  std_logic_vector(1 downto 0);  -- config address in
    CFGD     : in  std_logic_vector(31 downto 0);  -- config data in
    CFGQ     : out std_logic_vector(31 downto 0);  -- config data out
    CFGWEB   : in  std_logic;           -- config reg write enable (active low)
    --
    -- asynchronous
    RSTB    : in  std_logic;           -- global async reset (active low)
    PWD     : in  std_logic;           -- async power down (active high)
    RET     : in  std_logic;           -- async isolation signal (active high)
    --
    -- test signals
    TM       : in  std_logic;           -- test mode
    TE       : in  std_logic;           -- scan enable
    TD       : in  std_logic;           -- scan in
    TQ       : out std_logic;           -- scan out
    JTD      : in  std_logic;           -- scan in (jtag)
    JTQ      : out std_logic            -- scan out (jtag)
    );
end FLL_digital;


architecture rtl of FLL_digital is

  constant CLK_PERIOD_QUANTIZER_WIDTH : natural := 16;
  constant GAIN_WORDWIDTH             : natural := 4;
  constant DCO_WORDWIDTH              : natural := 10;
  constant DITHER_WORDWIDTH           : natural := 7;
  constant UNSTABLE_CYCLE_WIDTH       : natural := 6;
  constant STABLE_CYCLE_WIDTH         : natural := 6;
  constant LOCKTOLERANCE_WIDTH        : natural := 12;
  constant CLK_DIVIDER_WIDTH          : natural := 8;
  constant CFGREG_WIDTH               : natural := 32;

  ----------------------------------------------------------------------
  -- Signals/contants declarations -------------------------------------
  ----------------------------------------------------------------------
  signal CfgOpMode_S                  : std_logic;
  --
  signal CfgTargetRefClkMultFactor_D  : std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH-1 downto 0);
  signal RefClkMultFactor_D           : std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH-1 downto 0);
  --
  signal DitherValue_D                : std_logic_vector(DITHER_WORDWIDTH-1 downto 0);
  signal DitherPattern_D              : std_logic;
  signal DitherUpdate_S               : std_logic;
  signal DitherEnable_S               : std_logic;
  signal CfgDitherEnable_S            : std_logic;
  --
  signal FLLclkoutEnable_S            : std_logic;
  signal CfgLockGatedClkOut_S         : std_logic;
  --
  signal CfgDCOValueSTAmode_D         : std_logic_vector(DCO_WORDWIDTH-1 downto 0);
  signal DCOValue_D                   : std_logic_vector(DCO_WORDWIDTH-1 downto 0);
  signal DCOValueOut_D                : std_logic_vector(DCO_WORDWIDTH-1 downto 0);
  --
  signal Aberration_D                 : std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
  signal CfgGain_D                    : std_logic_vector(GAIN_WORDWIDTH-1 downto 0);
  signal CfgLockTolerance_D           : std_logic_vector(LOCKTOLERANCE_WIDTH-1 downto 0);
  signal CfgStableCycles_D            : std_logic_vector(STABLE_CYCLE_WIDTH-1 downto 0);
  signal CfgUnstableCycles_D          : std_logic_vector(UNSTABLE_CYCLE_WIDTH-1 downto 0);
  signal Lock_S                       : std_logic;
  signal LockReset_S                  : std_logic;
  --
  signal CfgReqSync_SP, CfgReqSync_SN : std_logic_vector(3 downto 0);
  signal CfgReqEdge_S                 : std_logic;
  --
  signal CfgAddr_SN, CfgAddr_SP       : std_logic_vector(1 downto 0);
  signal CfgReg1In_D, CfgReg1Out_D    : std_logic_vector(CFGREG_WIDTH-1 downto 0);
  signal CfgReg2In_D, CfgReg2Out_D    : std_logic_vector(CFGREG_WIDTH-1 downto 0);
  signal CfgReg1En_S                  : std_logic;
  signal CfgReg2En_S                  : std_logic;
  --
  signal ActMultFactorIn_D            : std_logic_vector(CFGREG_WIDTH-1 downto 0);
  signal ActMultFactorOut_D           : std_logic_vector(CFGREG_WIDTH-1 downto 0);
  signal StsRegEn_S                   : std_logic;
  --
  signal IntRegIn_D                   : std_logic_vector(CFGREG_WIDTH-1 downto 0);
  signal IntRegOut_D                  : std_logic_vector(CFGREG_WIDTH-1 downto 0);
  signal IntRegEn_S                   : std_logic;
  --
  signal IntIn_D                      : std_logic_vector(DCO_WORDWIDTH+10-1 downto 0);
  signal IntOut_D                     : std_logic_vector(DCO_WORDWIDTH+10-1 downto 0);
  --
  signal CfgOpenLoopWhenLocked_S      : std_logic;
  signal OpenLoop_S                   : std_logic;
  signal DelayDelta_S                 : std_logic;
  --
  signal CfgCfgClkSel_S               : std_logic;
  signal CfgClkSel_S                  : std_logic;
  --
  signal CfgFLLOutClkDiv_S            : std_logic_vector(log2ceil(CLK_DIVIDER_WIDTH+1)-1 downto 0);
  --
  signal FLLClk_C                     : std_logic;
  signal FBClkMuxIn_C                 : std_logic;
  signal FBClk_C                      : std_logic;
  signal CfgClkMuxOut_C               : std_logic;
  signal CfgClk_C                     : std_logic;

  ----------------------------------------------------------------------
  -- Default configuration register settings
  -- (see in the code section below for a complete description of
  --  the register bitmap)
  ----------------------------------------------------------------------

  constant STS_REG1_MASK : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    x"0000" & x"FFFF";
  constant STS_REG1_DEFAULT : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    x"0000" & x"0000";

  constant CFG_REG1_MASK : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    "11" & x"F" & "1111111111" & x"FFFF";
  constant CFG_REG1_DEFAULT : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    "01" & x"1" & "0010001000" & x"05F5";

  constant CFG_REG2_MASK : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    "1110" & x"FFF" & "111111" & "111111" & x"F";
  constant CFG_REG2_DEFAULT : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    "0000" & x"200" & "010000" & "010000" & x"7";

  constant INT_REG_MASK : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    std_logic_vector(to_unsigned(0, 16-DCO_WORDWIDTH)) & std_logic_vector(to_unsigned(2**IntIn_D'length-1, IntIn_D'length)) & std_logic_vector(to_unsigned(0, 16-(IntIn_D'length-DCO_WORDWIDTH)));
  constant INT_REG_DEFAULT : std_logic_vector(CFGREG_WIDTH-1 downto 0) :=
    x"00880000";

  ----------------------------------------------------------------------
  -- Components declarations -------------------------------------------
  ----------------------------------------------------------------------

  component FLL_loop_filter
    generic (
      CLK_PERIOD_QUANTIZER_WIDTH : natural;
      GAIN_WORDWIDTH             : natural;
      DCO_WORDWIDTH              : natural;
      FRACTIONAL_WORDWIDTH       : natural);
    port (
      Gain_SI          : in  std_logic_vector(GAIN_WORDWIDTH-1 downto 0);
      SetPoint_SI      : in  std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH-1 downto 0);
      ActMultFactor_DI : in  std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH-1 downto 0);
      Integrator_DI    : in  std_logic_vector(DCO_WORDWIDTH+10-1 downto 0);
      Integrator_DO    : out std_logic_vector(DCO_WORDWIDTH+10-1 downto 0);
      Aberration_DO    : out std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
      Enable_SI        : in  std_logic
      );
  end component;

  component FLL_settling_monitor
    generic (
      CLK_PERIOD_QUANTIZER_WIDTH : natural;
      LOCKTOLERANCE_WIDTH        : natural;
      STABLE_CYCLE_WIDTH         : natural;
      UNSTABLE_CYCLE_WIDTH       : natural);
    port (
      LockTolerance_DI  : in  std_logic_vector(LOCKTOLERANCE_WIDTH-1 downto 0);
      StableCycles_DI   : in  std_logic_vector(STABLE_CYCLE_WIDTH-1 downto 0);
      UnstableCycles_DI : in  std_logic_vector(UNSTABLE_CYCLE_WIDTH-1 downto 0);
      Aberration_DI     : in  std_logic_vector(CLK_PERIOD_QUANTIZER_WIDTH downto 0);
      Lock_SO           : out std_logic;
      LockReset_SI      : in  std_logic;
      OpMode_SI         : in  std_logic;
      RefClk_CI         : in  std_logic;
      DCOClk_CI         : in  std_logic;
      Rst_RBI           : in  std_logic);
  end component;

  component FLL_clk_period_quantizer
    generic (
      COUNTER_WIDTH : natural);
    port (
      DCOClk_CI  : in  std_logic;
      RefClk_CI  : in  std_logic;
      Rst_RBI    : in  std_logic;
      En_SI      : in  std_logic;
      Counter_DO : out std_logic_vector(COUNTER_WIDTH-1 downto 0));
  end component;

  component FLL_dither_pattern_gen
    generic (
      FRACTIONAL_BITS : natural);
    port (
      Frac_DI          : in  std_logic_vector(FRACTIONAL_BITS-1 downto 0);
      Update_SI        : in  std_logic;
      DitherPattern_DO : out std_logic;
      En_SI            : in  std_logic;
      Clk_CI           : in  std_logic;
      Rst_RBI          : in  std_logic
      );
  end component;

  component FLL_clk_divider
    generic (
      WIDTH : natural);
    port (
      Clk_CI     : in  std_logic;
      Rst_RBI    : in  std_logic;
      ClkOut0_CO : out std_logic;
      ClkOut1_CO : out std_logic;
      Select_SI  : in  std_logic_vector(log2ceil(WIDTH+1)-1 downto 0)
      );
  end component;

  component FLL_glitchfree_clkmux
    port (
      ClkIn0_CI : in  std_logic;
      ClkIn1_CI : in  std_logic;
      Select_SI : in  std_logic;
      ClkOut_CO : out std_logic;
      Rst_RBI   : in  std_logic);
  end component;

  component FLL_synchroedge
    generic (
      SYNCHRONIZERS : natural;
      RESET_VALUE   : std_logic);
    port (
      AsyncSignal_DI : in  std_logic;
      RisingEdge_DO  : out std_logic;
      En_SI          : in  std_logic;
      Clk_CI         : in  std_logic;
      Rst_RBI        : in  std_logic
      );
  end component;

  component FLL_reg
    generic (
      MASK    : std_logic_vector(32-1 downto 0);
      DEFAULT : std_logic_vector(32-1 downto 0));
    port (
      Data_DI : in  std_logic_vector(32-1 downto 0);
      Data_DO : out std_logic_vector(32-1 downto 0);
      Ena_SI  : in  std_logic;
      Clk_CI  : in  std_logic;
      Rst_RBI : in  std_logic);
  end component;

  component FLL_zerodelta
    generic (
      DELAY : natural);
    port (
      RefClk_CI     : in  std_logic;
      RetEn_SI      : in  std_logic;
      OpMode_SI     : in  std_logic;
      DCOEn_SBO     : out std_logic;
      DelayDelta_SO : out std_logic;
      TestMode_TI   : in  std_logic;
      Rst_RBI       : in  std_logic);
  end component;

  component FLL_clock_gated
    port (
      Clk_CO    : out std_logic;
      Clk_CI    : in  std_logic;
      Enable_SI : in  std_logic);
  end component;

  component FLL_mux
    port (
      Z_SO    : out std_logic;
      A_SI    : in  std_logic;
      B_SI    : in  std_logic;
      Sel_SI  : in  std_logic);
  end component;

begin

  -----------------------------------------------------------------------------
  -- Clock mux for config clock (glitch free mux)
  -- Change glitch-free between FBClkMuxIn_C (FBK) and REFCLK (REF)
  -----------------------------------------------------------------------------

  CfgClkSel_S <= '1' when (CfgCfgClkSel_S = '1') or (CfgOpMode_S = '1') else '0';

  i_cfgclkmux : FLL_glitchfree_clkmux
    port map (
      ClkIn0_CI => FBClkMuxIn_C,
      ClkIn1_CI => REFCLK,
      Select_SI => CfgClkSel_S,
      ClkOut_CO => CfgClkMuxOut_C,
      Rst_RBI   => RSTB);

  -----------------------------------------------------------------------------
  -- Clock muxes to make sure the flops are clocked from a toplevel clock pin
  -- in test mode
  -----------------------------------------------------------------------------

  i_fbclk_testclkmux : FLL_mux
    port map (
      A_SI   => FBClkMuxIn_C,
      B_SI   => REFCLK,
      Sel_SI => TM,
      Z_SO   => FBClk_C
      );
--  FBClk_C <= REFCLK when (TM = '1')  else FBClkMuxIn_C;

  i_cfgclk_testclkmux : FLL_mux
    port map (
      A_SI   => CfgClkMuxOut_C,
      B_SI   => REFCLK,
      Sel_SI => TM,
      Z_SO   => CfgClk_C
      );
--  CfgClk_C <= REFCLK when (TM = '1')  else CfgClkMuxOut_C;


  -----------------------------------------------------------------------------
  -- Output clock gate
  -----------------------------------------------------------------------------

  FLLclkoutEnable_S <= '0' when ((FLLOE = '0') or (TM = '1')) else Lock_S when CfgLockGatedClkOut_S = '1' else '1';

  -- Note: in the test mode the fll clock must be shut off

  i_flloutclkgate : FLL_clock_gated
    port map (
      Clk_CO    => FLLCLK,
      Clk_CI    => FLLClk_C,
      Enable_SI => FLLclkoutEnable_S);

  -----------------------------------------------------------------------------
  -- Lock output
  -----------------------------------------------------------------------------

  LOCK <= Lock_S;

  -----------------------------------------------------------------------------
  -- Clock divider
  -----------------------------------------------------------------------------

  i_clk_divider : FLL_clk_divider
    generic map (
      WIDTH => CLK_DIVIDER_WIDTH)
    port map (
      Clk_CI     => DCOCLK,
      Rst_RBI    => RSTB,
      ClkOut0_CO => FLLClk_C,
      ClkOut1_CO => FBClkMuxIn_C,
      Select_SI  => CfgFLLOutClkDiv_S);


  -----------------------------------------------------------------------------
  -- FLL loop filter and control unit
  -----------------------------------------------------------------------------

  i_loop_filter : FLL_loop_filter
    generic map (
      CLK_PERIOD_QUANTIZER_WIDTH => CLK_PERIOD_QUANTIZER_WIDTH,
      GAIN_WORDWIDTH             => GAIN_WORDWIDTH,
      DCO_WORDWIDTH              => DCO_WORDWIDTH,
      FRACTIONAL_WORDWIDTH       => 10)
    port map (
      Gain_SI          => CfgGain_D,
      SetPoint_SI      => CfgTargetRefClkMultFactor_D,
      --
      ActMultFactor_DI => ActMultFactorOut_D(15 downto 0),
      --
      Integrator_DI    => IntOut_D,
      Integrator_DO    => IntIn_D,
      Aberration_DO    => Aberration_D,
      --
      Enable_SI        => CfgOpMode_S
      );

  DCOValue_D <= std_logic_vector(IntOut_D(IntOut_D'length-1 downto IntOut_D'length-DCO_WORDWIDTH));

  -- Dithering requires the fractional bits of the Int_DI signal. Again, since
  -- Int_DI is in 2's complement format we can simple take the fractional bits
  -- as they are:
  --
  DitherValue_D <= std_logic_vector(IntOut_D(IntOut_D'length-DCO_WORDWIDTH-1 downto IntOut_D'length-DCO_WORDWIDTH-DITHER_WORDWIDTH));


  -----------------------------------------------------------------------------
  -- Monitor settling behavior both in the normal and the stand-alone mode
  -----------------------------------------------------------------------------

  i_settling_monitor : FLL_settling_monitor
    generic map (
      CLK_PERIOD_QUANTIZER_WIDTH => CLK_PERIOD_QUANTIZER_WIDTH,
      LOCKTOLERANCE_WIDTH        => LOCKTOLERANCE_WIDTH,
      STABLE_CYCLE_WIDTH         => STABLE_CYCLE_WIDTH,
      UNSTABLE_CYCLE_WIDTH       => UNSTABLE_CYCLE_WIDTH
      )
    port map (
      LockTolerance_DI  => CfgLockTolerance_D,
      StableCycles_DI   => CfgStableCycles_D,
      UnstableCycles_DI => CfgUnstableCycles_D,
      Aberration_DI     => Aberration_D,
      Lock_SO           => Lock_S,
      LockReset_SI      => LockReset_S,
      OpMode_SI         => CfgOpMode_S,
      RefClk_CI         => REFCLK,
      DCOClk_CI         => FBClk_C,
      Rst_RBI           => RSTB
      );

  -----------------------------------------------------------------------------
  -- Power down the R2R DAC by setting both its inputs and its inverted inputs
  -- to zero when the FLL is in reset
  -----------------------------------------------------------------------------

  DCOValueOut_D <= DCOValue_D when CfgOpMode_S = '1' else CfgDCOValueSTAmode_D;

  DCOD  <= (others => '1') when (RET = '1' or TM = '1') else DCOValueOut_D;
  DCODB <= (others => '1') when (RET = '1' or TM = '1') else (not DCOValueOut_D);
  --
  DITH  <= '1'             when (RET = '1' or TM = '1') else DitherPattern_D;
  DITHB <= '1'             when (RET = '1' or TM = '1') else (not DitherPattern_D);
  --
  --DCOPWD <= PWD; -- connection will be made in back-end flow
  --DCORET <= RET; -- connection will be made in back-end flow
  --
  DCOPWD <= PWD;
  DCORET <= RET;

  -----------------------------------------------------------------------------
  -- This unit has two purposes:
  -- 1) Mask the delta value after transition from stand-alone mode to
  -- closed loop mode, and when waking-up from seep.
  -- 2) Handle correct sequencing of the DCOENB signal when waking-up from sleep.
  -----------------------------------------------------------------------------

  i_dcoenb_and_zerodelta : FLL_zerodelta
    generic map (
      DELAY => 3)
    port map (
      RefClk_CI     => REFCLK,
      OpMode_SI     => CfgOpMode_S,
      RetEn_SI      => RET,
      DCOEn_SBO     => DCOENB,
      DelayDelta_SO => DelayDelta_S,
      TestMode_TI   => TM,
      Rst_RBI       => RSTB);

  -----------------------------------------------------------------------------
  -- Dither pattern generator.
  -- Works at the DCO clock speed (i.e., is in the DCO clock domain)
  -- For safety reasons the updates of the dither value are delayed by a couple
  -- of DCO clock cycles.
  -----------------------------------------------------------------------------

  DitherEnable_S <= '1' when ((CfgDitherEnable_S = '1') and (CfgOpMode_S = '1')) else '0';

  i_DitherUpdate_sync : FLL_synchroedge
    generic map (
      SYNCHRONIZERS => 4,
      RESET_VALUE   => '0')
    port map (
      AsyncSignal_DI => REFCLK,
      RisingEdge_DO  => DitherUpdate_S,
      En_SI          => DitherEnable_S,
      Clk_CI         => FBClk_C,
      Rst_RBI        => RSTB
      );

  i_dither_pattern_gen : FLL_dither_pattern_gen
    generic map (
      FRACTIONAL_BITS => DITHER_WORDWIDTH
      )
    port map (
      Frac_DI          => DitherValue_D,
      Update_SI        => DitherUpdate_S,
      DitherPattern_DO => DitherPattern_D,
      En_SI            => DitherEnable_S,
      Clk_CI           => FBClk_C,
      Rst_RBI          => RSTB
      );

  -----------------------------------------------------------------------------
  -- Measure the current multiplication factor.
  -- No synchronization with the ref clock domain required since the
  -- counter output is updated at the falling edge of the ref clock.
  -----------------------------------------------------------------------------

  i_clk_period_quantizer : FLL_clk_period_quantizer
    generic map (
      COUNTER_WIDTH => CLK_PERIOD_QUANTIZER_WIDTH)
    port map (
      DCOClk_CI  => FBClk_C,
      RefClk_CI  => REFCLK,
      Rst_RBI    => RSTB,
      En_SI      => '1',
      Counter_DO => RefClkMultFactor_D
      );


  -----------------------------------------------------------------------------
  -- Configuration update with handshake between interface clock domain
  -- and internal clock domain
  -----------------------------------------------------------------------------

  CfgReqSync_SN <= CfgReqSync_SP(2 downto 0) & CFGREQ;
  --
  CfgReqEdge_S  <= CfgReqSync_SP(1) and (not CfgReqSync_SP(2));
  --
  CFGACK        <= CfgReqSync_SP(3);

  cfg_handshake : process (CfgClk_C, RSTB)
  begin  -- process cfg_handshake
    if RSTB = '0' then                  -- asynchronous reset (active low)
      CfgReqSync_SP <= (others => '0');
      CfgAddr_SP    <= (others => '0');
      --
    elsif CfgClk_C'event and CfgClk_C = '1' then  -- rising clock edge
      --
      CfgReqSync_SP <= CfgReqSync_SN;
      --
      if CfgReqEdge_S = '1' then
        CfgAddr_SP <= CfgAddr_SN;
      end if;
      --
    end if;
  end process cfg_handshake;

  -- Reset the lock signal in any of the following cases :
  -- 1) write to cfg reg I in both OpModes
  -- 2) write to int reg in Normal Mode
  -- Note: write to cfg reg II should not deassert the lock. If the Lock mask
  -- is disabled in reg II the lock de-assert in the above cases will not
  -- interrupt the output clock signal.
  --
  LockReset_S <= '1' when (CfgReqEdge_S = '1' and CFGWEB = '0' and CFGAD = "01") else
                 '1' when (CfgReqEdge_S = '1' and CFGWEB = '0' and CFGAD = "11" and CfgOpMode_S = '1') else
                 '0';

  -----------------------------------------------------------------------------
  -- Configuration register
  -----------------------------------------------------------------------------
  --
  -- Status I Bitmap:
  --
  --   Bit range                            | Function
  --   ---------------------------------------------------------------------
  --   31 -- (CLK_PERIOD_QUANTIZER_WIDTH+1)  | unused
  --   (CLK_PERIOD_QUANTIZER_WIDTH-1) -- 0   | actual clk multiplication factor
  --
  -- this register is read-only
  --
  --
  -- CfgReg I Bitmap:
  --
  --   Bit range                            | Function
  --   ---------------------------------------------------------------------
  --   31                                   | startup op mode (1=normal, 0=stand-alone)
  --   30                                   | FLL clk output gated by lock signal
  --   29 -- 26                             | FLL output clock divider setting
  --   25 -- 16                             | clk frequency select in stand-alone mode
  --   15 -- 0                              | target clk multiplication factor
  --
  CfgOpMode_S                 <= CfgReg1Out_D(31);  -- def: 0 , efuse: 1
  CfgLockGatedClkOut_S        <= CfgReg1Out_D(30);  -- def: 1 , efuse: 0
  CfgFLLOutClkDiv_S           <= CfgReg1Out_D(29 downto 26);  -- def: 0x1
  CfgDCOValueSTAmode_D        <= CfgReg1Out_D(25 downto 16);
  CfgTargetRefClkMultFactor_D <= CfgReg1Out_D(15 downto 0);
  --
  --
  -- CfgReg II Bitmap
  --
  --   Bit range                             | Function
  --   ---------------------------------------------------------------------
  --   31                                    | dithering enable (active high)
  --   30                                    | open-loop-when-locked (active high)
  --   29                                    | config clock in STA mode (0=DCOCLK,1=REFCLK)
  --   28                                    | unused
  --   27-16                                 | lock tolerance
  --   15-10                                 | stable cycles to lock assert
  --   9-4                                   | unstable cycles to lock de-assert
  --   3 -- 0                                | gain setting
  --
  --
  CfgDitherEnable_S           <= CfgReg2Out_D(31);  -- def: 0
  CfgOpenLoopWhenLocked_S     <= CfgReg2Out_D(30);  -- def: 0
  CfgCfgClkSel_S              <= CfgReg2Out_D(29);  -- def: 0
  --CfgSeamlessTrans_S      <= CfgReg2Out_D(28);          -- def: 0
  --
  CfgLockTolerance_D          <= CfgReg2Out_D(27 downto 16);  -- def: 512
  CfgStableCycles_D           <= CfgReg2Out_D(15 downto 10);  -- def: 16
  CfgUnstableCycles_D         <= CfgReg2Out_D(9 downto 4);    -- def: 16
  --
  CfgGain_D                   <= CfgReg2Out_D(3 downto 0);    -- def: 0x7


  CfgAddr_SN <= CFGAD;
  --
  CfgReg1In_D <= CFGD;
  CfgReg2In_D <= CFGD;
  --
  IntRegIn_D  <= CFGD when ((CFGAD = "11") and (CFGWEB = '0')) else std_logic_vector(to_unsigned(0, 16-DCO_WORDWIDTH)) & IntIn_D & std_logic_vector(to_unsigned(0, 16-(IntIn_D'length-DCO_WORDWIDTH)));

  CFGQ <= ActMultFactorOut_D when CfgAddr_SP = "00" else
          CfgReg1Out_D when CfgAddr_SP = "01" else
          CfgReg2Out_D when CfgAddr_SP = "10" else
          IntRegOut_D  when CfgAddr_SP = "11" else
          (others => '0');

  OpenLoop_S  <= '1' when ((Lock_S = '1') and (CfgOpenLoopWhenLocked_S = '1'))                        else '0';

  StsRegEn_S  <= '0' when ((CfgReqSync_SP(2) = '1') and (CFGAD = "00"))                                         else '1';
  CfgReg1En_S <= '1' when ((CfgReqEdge_S = '1') and (CFGWEB = '0') and (CFGAD = "01"))                          else '0';
  CfgReg2En_S <= '1' when ((CfgReqEdge_S = '1') and (CFGWEB = '0') and (CFGAD = "10"))                          else '0';

  -- The int register must be clocked if ...
  -- 1) in the open-loop mode NEVER, EXCEPT WHEN ...
  --    ... it is being written
  -- 2) in the closed-loop mode ALWAYS, EXCEPT WHEN ...
  --    ... delayed activation is required OR ...
  --    ... the OpenLockedLoop-option is enabled and the loop is locked OR ...
  --    ... the reg is being read (as long as the CFGACK is asserted)
  IntRegEn_S  <= '1' when (((CfgReqEdge_S = '1') and (CFGWEB = '0') and (CFGAD = "11")) or ((CfgOpMode_S = '1') and (DelayDelta_S = '0') and (OpenLoop_S = '0') and (not((CFGWEB = '1') and (CFGAD = "11") and (CfgReqSync_SP(2)='1')))))  else '0';

  ActMultFactorIn_D <= x"0000" & RefClkMultFactor_D;
  IntOut_D          <= IntRegOut_D(16+DCO_WORDWIDTH-1 downto 16-(IntIn_D'length-DCO_WORDWIDTH));


  -- this is not an always on register
  i_statusreg : FLL_reg
    generic map(
      MASK    => STS_REG1_MASK,
      DEFAULT => STS_REG1_DEFAULT)
    port map (
      Data_DI => ActMultFactorIn_D,
      Data_DO => ActMultFactorOut_D,
      Ena_SI  => StsRegEn_S,
      Clk_CI  => REFCLK,
      Rst_RBI => RSTB);

  -- always-on register
  i_cfgreg_1_ao : FLL_reg
    generic map (
      MASK    => CFG_REG1_MASK,
      DEFAULT => CFG_REG1_DEFAULT)
    port map (
      Data_DI => CfgReg1In_D,
      Data_DO => CfgReg1Out_D,
      Ena_SI  => CfgReg1En_S,
      Clk_CI  => CfgClk_C,
      Rst_RBI => RSTB);

  -- always-on register
  i_cfgreg_2_ao : FLL_reg
    generic map (
      MASK    => CFG_REG2_MASK,
      DEFAULT => CFG_REG2_DEFAULT)
    port map (
      Data_DI => CfgReg2In_D,
      Data_DO => CfgReg2Out_D,
      Ena_SI  => CfgReg2En_S,
      Clk_CI  => CfgClk_C,
      Rst_RBI => RSTB);

  -- always-on register
  i_intreg_ao : FLL_reg
    generic map(
      MASK    => INT_REG_MASK,
      DEFAULT => INT_REG_DEFAULT)
    port map (
      Data_DI => IntRegIn_D,
      Data_DO => IntRegOut_D,
      Ena_SI  => IntRegEn_S,
      Clk_CI  => CfgClk_C,
      Rst_RBI => RSTB);



end rtl;

