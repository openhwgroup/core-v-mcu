-------------------------------------------------------------------------------
-- Title      : Digitally Controlled Oscillator
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : gf22_DCO_model.wc.vhd
-- Author     : David Bellasi <bellasi@ee.ethz.ch>
-- Company    : Integrated Systems Laboratory, ETH Zurich
-- Created    : 2016-10-18
-------------------------------------------------------------------------------
-- Description: Behavioral model of the Digitally Controlled Oscillator (DCO).
--              The model is a 5th order approximation of the DCO transfer
--              function obtained from circuit simulations with spectre.
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
-- 2017-01-30  3.1      muheim              change it to tech independens
-- 2017-05-31  3.1a     muheim              set the Freq_DO to '0' when it is not enabled
-- 2017-06-05  3.1b     muheim              modeled it linear in 2 pieces
-- 2017-06-07  3.1c     muheim/bellasid     fit according to the wc simulation
-- 2017-06-13  3.1d     muheim/bellasid     fit according to the wc C-CC back annotated simulation
-- 2017-08-29  3.1e     muheim              change the clock generation process so that end of the
--                                          simulation, the process stooping (the reset have to go low)
-- 2017-08-30  3.2      muheim              ported to gf22 and cleaning
-- 2017-10-02  3.2a     bellasid            fit according to the tc R-C-CC back annotated simulation
-- 2017-10-02  3.2b     muheim              modeling the DCO more accurate:
--                                          - adding a delay for the start of the clock after enable
--                                          - adding a low pass filter for the control word.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity gf22_DCO is
  port (
    Din_DI   : in  std_logic_vector(9 downto 0);
    En_SBI   : in  std_logic;
    Freq_DO  : out std_logic;
    FreqReal : out real
    );

end gf22_DCO;


architecture behavioral of gf22_DCO is

  signal LocalClock_C   : std_logic := '0';
  signal HALF_PERIOD_NS : time      := 1.0 ns;
  signal go : std_logic;
  signal DinZ_D   :  integer;
  signal Din_D    :  integer;


begin  -- Behavioral

  pDinFilter : process
  begin

    loop
      while En_SBI = '0' loop
        wait for 2 ns;
        Din_D <=  integer(real(0.1) * real(to_integer(unsigned(Din_DI))) + real(0.9) * real(DinZ_D)) ;
        wait for 0 ns;
        DinZ_D <= Din_D;
      end loop ;
      wait until En_SBI = '0';
    end loop ;
  end process ;


  pFreq : process(Din_D, En_SBI)
    variable din_integer  : integer;
    variable din_real     : real;
    variable freq_real    : real;
  begin

    go <= '0';

    din_integer := Din_D;
    din_real := real(din_integer);

    if din_integer < 87 then
      freq_real := 0.000001;
    elsif din_integer < 387 then
      freq_real :=  real(1.146447306837584E+2) + real(-6.962) + real(-2.526244559679558)*din_real + real(0.016899033599727)*din_real**2.0 + real(-1.455504767744425E-5)*din_real**3.0;
      go <= '1';
    else
      freq_real :=  real(-1.210565451926972E+3) + real(5.687701158516602)*din_real + real(-0.001156561922360)*din_real**2.0;
      go <= '1';
    end if;

    HALF_PERIOD_NS <= (1.0 / (2.0 * freq_real)) * 1 us;

    if En_SBI = '0' then
      FreqReal <= freq_real;
    else
      FreqReal <= real(0.0);
    end if;

  end process;


  clk_out : process(LocalClock_C, go, En_SBI)
  begin  -- process clk_out

    if go = '1' and En_SBI = '0' then
      if LocalClock_C'event then
        LocalClock_C <= not(LocalClock_C) after HALF_PERIOD_NS;
      else
        LocalClock_C  <= '0' after 34 ns;

      end if;

    else
      LocalClock_C  <= '1';

    end if;

  end process clk_out;


  Freq_DO <= LocalClock_C;


end behavioral;



