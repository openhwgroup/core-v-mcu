-------------------------------------------------------------------------------
-- Title      : top level model
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : gf22_FLL_model.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: Behavioral model of the complete FLL, including behavioral
--              model of the DCO and RTL of the digital section
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
-- 2017-01-30  3.1      muheim              change it to tech independens
-- 2017-08-29  3.2      muheim              ported to gf22
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity gf22_FLL is

  port (
    FLLCLK : out std_logic;
    FLLOE  : in  std_logic;
    REFCLK : in  std_logic;
    LOCK   : out std_logic;
    CFGREQ : in  std_logic;
    CFGACK : out std_logic;
    CFGAD  : in  std_logic_vector(1 downto 0);
    CFGD   : in  std_logic_vector(31 downto 0);
    CFGQ   : out std_logic_vector(31 downto 0);
    CFGWEB : in  std_logic;
    RSTB   : in  std_logic;
    PWD    : in  std_logic;
    RET    : in  std_logic;
    TM     : in  std_logic;
    TE     : in  std_logic;
    TD     : in  std_logic;
    TQ     : out std_logic;
    JTD    : in  std_logic;
    JTQ    : out std_logic);

end gf22_FLL;


architecture behavioral of gf22_FLL is

  signal DCOClk_C      : std_logic;
  signal DCO_D         : std_logic_vector(9 downto 0);
  signal DCO_DB        : std_logic_vector(9 downto 0);
  signal DCOEn_SB      : std_logic;
  signal FreqReal      : real := 0.0;
  signal OpMode_SB : std_logic;

  component gf22_DCO
    port (
      Din_DI   : in  std_logic_vector(9 downto 0);
      En_SBI   : in  std_logic;
      Freq_DO  : out std_logic;
      FreqReal : out real
      );
  end component;

  component FLL_digital
    port (
      DITH     : out std_logic;
      DITHB    : out std_logic;
      DCOCLK   : in  std_logic;
      FLLCLK   : out std_logic;
      FLLOE    : in  std_logic;
      DCOD     : out std_logic_vector(9 downto 0);
      DCODB    : out std_logic_vector(9 downto 0);
      DCOENB   : out std_logic;
      DCOPWD   : out std_logic;
      DCORET   : out std_logic;
      REFCLK   : in  std_logic;
      LOCK     : out std_logic;
      CFGREQ   : in  std_logic;
      CFGACK   : out std_logic;
      CFGAD    : in  std_logic_vector(1 downto 0);
      CFGD     : in  std_logic_vector(31 downto 0);
      CFGQ     : out std_logic_vector(31 downto 0);
      CFGWEB   : in  std_logic;
      RSTB     : in  std_logic;
      PWD      : in  std_logic;
      RET      : in  std_logic;
      TM       : in  std_logic;
      TE       : in  std_logic;
      TD       : in  std_logic;
      TQ       : out std_logic;
      JTD      : in  std_logic;
      JTQ      : out std_logic);
  end component;

begin

  DCO_D <= not DCO_DB;

  i_gf22_DCO : gf22_DCO
    port map (
      Din_DI   => DCO_D,
      En_SBI   => DCOEn_SB,
      Freq_DO  => DCOClk_C,
      FreqReal => FreqReal
      );


  i_FLL_digital : FLL_digital
    port map (
      DITH     => open,
      DITHB    => open,
      DCOCLK   => DCOClk_C,
      FLLCLK   => FLLCLK,
      FLLOE    => FLLOE,
      DCOD     => open,
      DCODB    => DCO_DB,
      DCOENB   => DCOEn_SB,
      DCOPWD   => open,
      DCORET   => open,
      REFCLK   => REFCLK,
      LOCK     => LOCK,
      CFGREQ   => CFGREQ,
      CFGACK   => CFGACK,
      CFGAD    => CFGAD,
      CFGD     => CFGD,
      CFGQ     => CFGQ,
      CFGWEB   => CFGWEB,
      RSTB     => RSTB,
      PWD      => PWD,
      RET      => RET,
      TM       => TM,
      TE       => TE,
      TD       => TD,
      TQ       => TQ,
      JTD      => JTD,
      JTQ      => JTQ
      );

end behavioral;

