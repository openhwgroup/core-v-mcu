-------------------------------------------------------------------------------
-- Title      : FLL Package
-- Project    : Frequency Locked Loop (FLL) - IIS/DZ
-------------------------------------------------------------------------------
-- File       : FLLPkg.vhd
-- Company    : Integrated Systems Laboratory, ETH Zurich
-------------------------------------------------------------------------------
-- Description: This package contains the log2(x) functions.
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package FLLPkg is

  -----------------------------------------------------------------------------
  -- Ceil(Log2(x))
  -----------------------------------------------------------------------------
  function log2ceil (n : natural) return natural;


end FLLPkg;

package body FLLPkg is

  -- purpose : computes ceil(log2(n)) to get "bit width"
  function log2ceil (n : natural) return natural is
  begin  -- log2ceil
    if n = 0 then
      return 0;
    end if;
    for index in 1 to 32 loop
      if (2**index >= n) then
        return index;
      end if;
    end loop;  -- n
  end log2ceil;

end FLLPkg;


