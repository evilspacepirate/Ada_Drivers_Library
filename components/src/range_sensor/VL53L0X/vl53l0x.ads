------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2017, AdaCore                           --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of STMicroelectronics nor the names of its       --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
--                                                                          --
--  This file is based on X-CUBE-53L0A1 STM32Cube expansion                 --
--                                                                          --
--   COPYRIGHT(c) 2016 STMicroelectronics                                   --
------------------------------------------------------------------------------

with HAL.I2C;
with Interfaces; use Interfaces;

package VL53L0X is

   Fix_Point_16_16_Delta : constant := 1.0 / (2.0 ** 16);

   type Fix_Point_16_16 is
     delta Fix_Point_16_16_Delta
     range -2.0 ** 15 .. 2.0 ** 15 - Fix_Point_16_16_Delta
     with Size => 32;

   type VL53L0X_Ranging_Sensor
     (Port  : not null HAL.I2C.Any_I2C_Port) is limited private;

   type VL53L0X_GPIO_Functionality is
     (No_Interrupt,
      Level_Low,
      Level_High,
      Out_Of_Window,
      New_Sample_Ready);

   type VL53L0X_Interrupt_Polarity is
     (Polarity_Low,
      Polarity_High);

   procedure Initialize
     (This : in out VL53L0X_Ranging_Sensor);

   function Read_Id (This : VL53L0X_Ranging_Sensor) return HAL.UInt16;

   procedure Set_Device_Address
     (This   : in out VL53L0X_Ranging_Sensor;
      Addr   : HAL.I2C.I2C_Address;
      Status : out Boolean);

   function Data_Init
     (This : in out VL53L0X_Ranging_Sensor) return Boolean;

   function Static_Init
     (This : in out VL53L0X_Ranging_Sensor) return Boolean;

   function Perform_Ref_Calibration
     (This : in out VL53L0X_Ranging_Sensor) return Boolean;

   function Read_Range_Single_Millimeters
     (This : VL53L0X_Ranging_Sensor) return HAL.UInt16;

   function Set_GPIO_Config
     (This          : in out VL53L0X_Ranging_Sensor;
      Functionality : VL53L0X_GPIO_Functionality;
      Polarity      : VL53L0X_Interrupt_Polarity) return Boolean;

   procedure Clear_Interrupt_Mask
     (This : VL53L0X_Ranging_Sensor);

   function Get_Measurement_Timing_Budget
     (This : VL53L0X_Ranging_Sensor) return HAL.UInt32;

   function Set_Measurement_Timing_Budget
     (This                 : VL53L0X_Ranging_Sensor;
      Budget_Micro_Seconds : HAL.UInt32) return Boolean;

private

   REG_SYSRANGE_START           : constant := 16#000#;
   --  mask existing bit in #REG_SYSRANGE_START
   REG_SYSRANGE_MODE_MASK       : constant := 16#0F#;
   --  bit 0 in #REG_SYSRANGE_START write 1 toggle state in
   --  continuous mode and arm next shot in single shot mode
   REG_SYSRANGE_MODE_START_STOP : constant := 16#01#;
   --  bit 1 write 0 in #REG_SYSRANGE_START set single shot mode
   REG_SYSRANGE_MODE_SINGLESHOT : constant := 16#00#;
   --  bit 1 write 1 in #REG_SYSRANGE_START set back-to-back
   --  operation mode
   REG_SYSRANGE_MODE_BACKTOBACK : constant := 16#02#;
   --  bit 2 write 1 in #REG_SYSRANGE_START set timed operation
   --  mode
   REG_SYSRANGE_MODE_TIMED      : constant := 16#04#;
   --  bit 3 write 1 in #REG_SYSRANGE_START set histogram operation
   --  mode
   REG_SYSRANGE_MODE_HISTOGRAM  : constant := 16#08#;


   REG_SYSTEM_THRESH_HIGH : constant := 16#000C#;
   REG_SYSTEM_THRESH_LOW  : constant := 16#000E#;


   REG_SYSTEM_SEQUENCE_CONFIG         : constant := 16#0001#;
   REG_SYSTEM_RANGE_CONFIG            : constant := 16#0009#;
   REG_SYSTEM_INTERMEASUREMENT_PERIOD : constant := 16#0004#;


   REG_SYSTEM_INTERRUPT_CONFIG_GPIO           : constant := 16#000A#;
   REG_SYSTEM_INTERRUPT_GPIO_DISABLED         : constant := 16#00#;
   REG_SYSTEM_INTERRUPT_GPIO_LEVEL_LOW        : constant := 16#01#;
   REG_SYSTEM_INTERRUPT_GPIO_LEVEL_HIGH       : constant := 16#02#;
   REG_SYSTEM_INTERRUPT_GPIO_OUT_OF_WINDOW    : constant := 16#03#;
   REG_SYSTEM_INTERRUPT_GPIO_NEW_SAMPLE_READY : constant := 16#04#;

   REG_GPIO_HV_MUX_ACTIVE_HIGH : constant := 16#0084#;

   REG_SYSTEM_INTERRUPT_CLEAR  : constant := 16#000B#;

   --  Result registers
   REG_RESULT_INTERRUPT_STATUS                     : constant := 16#0013#;
   REG_RESULT_RANGE_STATUS                         : constant := 16#0014#;

   REG_RESULT_CORE_PAGE                            : constant := 1;
   REG_RESULT_CORE_AMBIENT_WINDOW_EVENTS_RTN       : constant := 16#00BC#;
   REG_RESULT_CORE_RANGING_TOTAL_EVENTS_RTN        : constant := 16#00C0#;
   REG_RESULT_CORE_AMBIENT_WINDOW_EVENTS_REF       : constant := 16#00D0#;
   REG_RESULT_CORE_RANGING_TOTAL_EVENTS_REF        : constant := 16#00D4#;
   REG_RESULT_PEAK_SIGNAL_RATE_REF                 : constant := 16#00B6#;

   --  Algo register

   REG_ALGO_PART_TO_PART_RANGE_OFFSET_MM           : constant := 16#0028#;

   REG_I2C_SLAVE_DEVICE_ADDRESS                    : constant := 16#008A#;

   --  Check Limit registers
   REG_MSRC_CONFIG_CONTROL                         : constant := 16#0060#;

   REG_PRE_RANGE_CONFIG_MIN_SNR                    : constant := 16#0027#;
   REG_PRE_RANGE_CONFIG_VALID_PHASE_LOW            : constant := 16#0056#;
   REG_PRE_RANGE_CONFIG_VALID_PHASE_HIGH           : constant := 16#0057#;
   REG_PRE_RANGE_MIN_COUNT_RATE_RTN_LIMIT          : constant := 16#0064#;

   REG_FINAL_RANGE_CONFIG_MIN_SNR                  : constant := 16#0067#;
   REG_FINAL_RANGE_CONFIG_VALID_PHASE_LOW          : constant := 16#0047#;
   REG_FINAL_RANGE_CONFIG_VALID_PHASE_HIGH         : constant := 16#0048#;
   REG_FINAL_RANGE_CONFIG_MIN_COUNT_RATE_RTN_LIMIT : constant := 16#0044#;

   REG_PRE_RANGE_CONFIG_SIGMA_THRESH_HI            : constant := 16#0061#;
   REG_PRE_RANGE_CONFIG_SIGMA_THRESH_LO            : constant := 16#0062#;

   --  PRE RANGE registers
   REG_PRE_RANGE_CONFIG_VCSEL_PERIOD               : constant := 16#0050#;
   REG_PRE_RANGE_CONFIG_TIMEOUT_MACROP_HI          : constant := 16#0051#;
   REG_PRE_RANGE_CONFIG_TIMEOUT_MACROP_LO          : constant := 16#0052#;

   REG_SYSTEM_HISTOGRAM_BIN                  : constant := 16#0081#;
   REG_HISTOGRAM_CONFIG_INITIAL_PHASE_SELECT : constant := 16#0033#;
   REG_HISTOGRAM_CONFIG_READOUT_CTRL         : constant := 16#0055#;

   REG_FINAL_RANGE_CONFIG_VCSEL_PERIOD       : constant := 16#0070#;
   REG_FINAL_RANGE_CONFIG_TIMEOUT_MACROP_HI  : constant := 16#0071#;
   REG_FINAL_RANGE_CONFIG_TIMEOUT_MACROP_LO  : constant := 16#0072#;
   REG_CROSSTALK_COMPENSATION_PEAK_RATE_MCPS : constant := 16#0020#;

   REG_MSRC_CONFIG_TIMEOUT_MACROP : constant := 16#0046#;

   REG_SOFT_RESET_GO2_SOFT_RESET_N : constant := 16#00bf#;
   REG_IDENTIFICATION_MODEL_ID     : constant := 16#00c0#;
   REG_IDENTIFICATION_REVISION_ID  : constant := 16#00c2#;

   REG_OSC_CALIBRATE_VAL : constant := 16#00f8#;

   SIGMA_ESTIMATE_MAX_VALUE : constant := 65535;
   --  equivalent to a range sigma of 655.35mm

   REG_GLOBAL_CONFIG_VCSEL_WIDTH : constant := 16#032#;
   REG_GLOBAL_CONFIG_SPAD_ENABLES_REF_0 : constant := 16#0B0#;
   REG_GLOBAL_CONFIG_SPAD_ENABLES_REF_1 : constant := 16#0B1#;
   REG_GLOBAL_CONFIG_SPAD_ENABLES_REF_2 : constant := 16#0B2#;
   REG_GLOBAL_CONFIG_SPAD_ENABLES_REF_3 : constant := 16#0B3#;
   REG_GLOBAL_CONFIG_SPAD_ENABLES_REF_4 : constant := 16#0B4#;
   REG_GLOBAL_CONFIG_SPAD_ENABLES_REF_5 : constant := 16#0B5#;

   REG_GLOBAL_CONFIG_REF_EN_START_SELECT : constant := 16#B6#;
   REG_DYNAMIC_SPAD_NUM_REQUESTED_REF_SPAD : constant := 16#4E#;
   REG_DYNAMIC_SPAD_REF_EN_START_OFFSET : constant := 16#4F#;
   REG_POWER_MANAGEMENT_GO1_POWER_FORCE : constant := 16#80#;

   --  Speed of light in um per 1E-10 Seconds
   SPEED_OF_LIGHT_IN_AIR : constant := 2997;

   REG_VHV_CONFIG_PAD_SCL_SDA_EXTSUP_HV : constant := 16#0089#;

   REG_ALGO_PHASECAL_LIM : constant := 16#0030#;
   REG_ALGO_PHASECAL_CONFIG_TIMEOUT : constant := 16#0030#;

   type VL53L0X_Device_Specific_Parameters is record
      Osc_Frequency      : HAL.UInt32 := 0;
      Last_Timeout       : HAL.UInt16 := 0;

      Pin0_Functionality : VL53L0X_GPIO_Functionality := No_Interrupt;

      Final_Range_Timeout_Micro_Seconds : HAL.UInt32 := 0;
      Final_Range_Vcsel_Pulse_Period    : HAL.Byte := 0;
      Pre_Range_Timeout_Micro_Seconds   : HAL.UInt32 := 0;
      Pre_Range_Vcsel_Pulse_Period      : HAL.Byte := 0;

      Sigma_Est_Ref_Array               : HAL.UInt16 := 0;
      Sigma_Est_Eff_Pulso_Width         : HAL.UInt16 := 0;
      Sigma_Est_Eff_Amb_Width           : HAL.UInt16 := 0;

      Read_Data_From_Device_Done        : Boolean := False;
      Module_Id                         : HAL.Byte;
      Revision                          : HAL.Byte;
      Reference_SPAD_Count              : HAL.Byte;
      Reference_SPAD_Type               : HAL.Byte;
      Reference_SPADs_Initialised       : Boolean := False;

      Part_UID_Upper                    : HAL.UInt32;
      Part_UID_Lower                    : HAL.UInt32;
   end record;

   type VL53L0X_Ranging_Sensor (Port : not null HAL.I2C.Any_I2C_Port)
   is limited record
      --  Default address: can be changed by software
      I2C_Address            : HAL.I2C.I2C_Address := 16#52#;
      Stop_Variable          : Unsigned_8;
   end record;

   procedure I2C_Write
     (This   : VL53L0X_Ranging_Sensor;
      Data   : HAL.Byte_Array;
      Status : out Boolean);

   procedure I2C_Read
     (This   : VL53L0X_Ranging_Sensor;
      Data   : out HAL.Byte_Array;
      Status : out Boolean);

   procedure Write
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : HAL.Byte_Array;
      Status : out Boolean);
   procedure Write
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : HAL.Byte;
      Status : out Boolean);
   procedure Write
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : HAL.UInt16;
      Status : out Boolean);
   procedure Write
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : HAL.UInt32;
      Status : out Boolean);

   procedure Read
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : out HAL.Byte_Array;
      Status : out Boolean);
   procedure Read
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : out HAL.Byte;
      Status : out Boolean);
   procedure Read
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : out HAL.UInt16;
      Status : out Boolean);
   procedure Read
     (This   : VL53L0X_Ranging_Sensor;
      Index  : HAL.Byte;
      Data   : out HAL.UInt32;
      Status : out Boolean);

   function Set_Signal_Rate_Limit
     (This       : VL53L0X_Ranging_Sensor;
      Limit_Mcps : Fix_Point_16_16) return Boolean;

   function Get_SPAD_Info
     (This        : VL53L0X_Ranging_Sensor;
      SPAD_Count  : out HAL.Byte;
      Is_Aperture : out Boolean) return Boolean;

   type VL53L0x_Sequence_Step is
     (TCC, DSS, MSRC, Pre_Range, Final_Range);

   type VL53L0x_Sequence_Step_Enabled is
     array (VL53L0x_Sequence_Step) of Boolean;

   type VL53L0x_Sequence_Step_Timeout is
     array (VL53L0x_Sequence_Step) of HAL.UInt32;

   function Get_Sequence_Step_Enabled
     (This : VL53L0X_Ranging_Sensor) return VL53L0x_Sequence_Step_Enabled;

   function Sequence_Step_Timeout
     (This : VL53L0X_Ranging_Sensor;
      Step : VL53L0x_Sequence_Step) return HAL.UInt32;

   function Get_VCSel_Pulse_Period
     (This     : VL53L0X_Ranging_Sensor;
      Sequence : VL53L0x_Sequence_Step) return HAL.Byte;

end VL53L0X;
