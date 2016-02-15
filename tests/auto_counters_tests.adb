-- Auto_Counters_Tests
-- Unit tests for Auto_Counters packages

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Auto_Counters_Suite;

with AUnit.Run;
with AUnit.Reporter.Text;

procedure Auto_Counters_Tests is
   procedure Run is new AUnit.Run.Test_Runner (Auto_Counters_Suite.Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   AUnit.Reporter.Text.Set_Use_ANSI_Colors(Reporter, True);
   Run (Reporter);
end Auto_Counters_Tests;
