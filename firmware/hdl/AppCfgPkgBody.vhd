-- Copyright Till Straumann, 2023. Licensed under the EUPL-1.2 or later.
-- You may obtain a copy of the license at
--   https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
-- This notice must not be removed.

-- THIS FILE WAS AUTOMATICALLY GENERATED; DO NOT EDIT!

-- Generated with: 'genAppCfgPkgBody.py -f ../hdl/AppCfgPkgBody.vhd ../hdl/tic_nic.yaml':
--
-- deviceDesc:
--   configurationDesc:
--     functionNCM:
--       enabled: true
--       haveDynamicMACAddress: true
--       iFunction: Tic-Nic PTP Ethernet Adapter
--       iMACAddress: 02deadbeef31
--       numMulticastFilters: 32800
--     functionUAC2Input:
--       enabled: true
--       iFunction: Mecatica Microphone Test
--       iInputTerminal:
--       - Sin-Test
--       - CIC-1stg
--       - CIC-2stg
--       - CIC-3stg
--       - CIC-4stg
--       iSelector: Mecatica Mic Capture
--       numBits: 16
--       numChannels: 1
--   iProduct: Till's Mecatica USB Example Device
--   idProduct: 1
--

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

use     work.Usb2Pkg.all;

package body Usb2AppCfgPkg is
   function usb2AppGetDescriptors return Usb2ByteArray is
      constant c : Usb2ByteArray := (
      -- Usb2DeviceDesc
        0 => x"12",  -- bLength
        1 => x"01",  -- bDescriptorType
        2 => x"00",  -- bcdUSB
        3 => x"02",
        4 => x"ef",  -- bDeviceClass
        5 => x"02",  -- bDeviceSubClass
        6 => x"01",  -- bDeviceProtocol
        7 => x"40",  -- bMaxPacketSize0
        8 => x"09",  -- idVendor
        9 => x"12",
       10 => x"01",  -- idProduct
       11 => x"00",
       12 => x"00",  -- bcdDevice
       13 => x"01",
       14 => x"00",  -- iManufacturer
       15 => x"01",  -- iProduct
       16 => x"00",  -- iSerialNumber
       17 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
       18 => x"0a",  -- bLength
       19 => x"06",  -- bDescriptorType
       20 => x"00",  -- bcdUSB
       21 => x"02",
       22 => x"ef",  -- bDeviceClass
       23 => x"02",  -- bDeviceSubClass
       24 => x"01",  -- bDeviceProtocol
       25 => x"40",  -- bMaxPacketSize0
       26 => x"01",  -- bNumConfigurations
       27 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
       28 => x"09",  -- bLength
       29 => x"02",  -- bDescriptorType
       30 => x"74",  -- wTotalLength
       31 => x"01",
       32 => x"06",  -- bNumInterfaces
       33 => x"01",  -- bConfigurationValue
       34 => x"00",  -- iConfiguration
       35 => x"a0",  -- bmAttributes
       36 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
       37 => x"08",  -- bLength
       38 => x"0b",  -- bDescriptorType
       39 => x"00",  -- bFirstInterface
       40 => x"02",  -- bInterfaceCount
       41 => x"02",  -- bFunctionClass
       42 => x"02",  -- bFunctionSubClass
       43 => x"00",  -- bFunctionProtocol
       44 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
       45 => x"09",  -- bLength
       46 => x"04",  -- bDescriptorType
       47 => x"00",  -- bInterfaceNumber
       48 => x"00",  -- bAlternateSetting
       49 => x"01",  -- bNumEndpoints
       50 => x"02",  -- bInterfaceClass
       51 => x"02",  -- bInterfaceSubClass
       52 => x"00",  -- bInterfaceProtocol
       53 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
       54 => x"05",  -- bLength
       55 => x"24",  -- bDescriptorType
       56 => x"00",  -- bDescriptorSubtype
       57 => x"20",  -- bcdCDC
       58 => x"01",
      -- Usb2CDCFuncCallManagementDesc
       59 => x"05",  -- bLength
       60 => x"24",  -- bDescriptorType
       61 => x"01",  -- bDescriptorSubtype
       62 => x"00",  -- bmCapabilities
       63 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
       64 => x"04",  -- bLength
       65 => x"24",  -- bDescriptorType
       66 => x"02",  -- bDescriptorSubtype
       67 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
       68 => x"05",  -- bLength
       69 => x"24",  -- bDescriptorType
       70 => x"06",  -- bDescriptorSubtype
       71 => x"00",  -- bControlInterface
       72 => x"01",
      -- Usb2EndpointDesc
       73 => x"07",  -- bLength
       74 => x"05",  -- bDescriptorType
       75 => x"82",  -- bEndpointAddress
       76 => x"03",  -- bmAttributes
       77 => x"08",  -- wMaxPacketSize
       78 => x"00",
       79 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
       80 => x"09",  -- bLength
       81 => x"04",  -- bDescriptorType
       82 => x"01",  -- bInterfaceNumber
       83 => x"00",  -- bAlternateSetting
       84 => x"02",  -- bNumEndpoints
       85 => x"0a",  -- bInterfaceClass
       86 => x"00",  -- bInterfaceSubClass
       87 => x"00",  -- bInterfaceProtocol
       88 => x"00",  -- iInterface
      -- Usb2EndpointDesc
       89 => x"07",  -- bLength
       90 => x"05",  -- bDescriptorType
       91 => x"81",  -- bEndpointAddress
       92 => x"02",  -- bmAttributes
       93 => x"40",  -- wMaxPacketSize
       94 => x"00",
       95 => x"00",  -- bInterval
      -- Usb2EndpointDesc
       96 => x"07",  -- bLength
       97 => x"05",  -- bDescriptorType
       98 => x"01",  -- bEndpointAddress
       99 => x"02",  -- bmAttributes
      100 => x"40",  -- wMaxPacketSize
      101 => x"00",
      102 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      103 => x"08",  -- bLength
      104 => x"0b",  -- bDescriptorType
      105 => x"02",  -- bFirstInterface
      106 => x"02",  -- bInterfaceCount
      107 => x"01",  -- bFunctionClass
      108 => x"00",  -- bFunctionSubClass
      109 => x"20",  -- bFunctionProtocol
      110 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      111 => x"09",  -- bLength
      112 => x"04",  -- bDescriptorType
      113 => x"02",  -- bInterfaceNumber
      114 => x"00",  -- bAlternateSetting
      115 => x"00",  -- bNumEndpoints
      116 => x"01",  -- bInterfaceClass
      117 => x"01",  -- bInterfaceSubClass
      118 => x"20",  -- bInterfaceProtocol
      119 => x"00",  -- iInterface
      -- Usb2UAC2FuncHeaderDesc
      120 => x"09",  -- bLength
      121 => x"24",  -- bDescriptorType
      122 => x"01",  -- bDescriptorSubtype
      123 => x"00",  -- bcdADC
      124 => x"02",
      125 => x"03",  -- bCategory
      126 => x"8c",  -- wTotalLength
      127 => x"00",
      128 => x"00",  -- bmControls
      -- Usb2UAC2ClockSourceDesc
      129 => x"08",  -- bLength
      130 => x"24",  -- bDescriptorType
      131 => x"0a",  -- bDescriptorSubtype
      132 => x"09",  -- bClockID
      133 => x"00",  -- bmAttributes
      134 => x"01",  -- bmControls
      135 => x"00",  -- bAssocTerminal
      136 => x"00",  -- iClockSource
      -- Usb2UAC2InputTerminalDesc
      137 => x"11",  -- bLength
      138 => x"24",  -- bDescriptorType
      139 => x"02",  -- bDescriptorSubtype
      140 => x"01",  -- bTerminalID
      141 => x"01",  -- wTerminalType
      142 => x"02",
      143 => x"00",  -- bAssocTerminal
      144 => x"09",  -- bCSourceID
      145 => x"01",  -- bNrChannels
      146 => x"04",  -- bmChannelConfig
      147 => x"00",
      148 => x"00",
      149 => x"00",
      150 => x"00",  -- iChannelNames
      151 => x"00",  -- bmControls
      152 => x"00",
      153 => x"04",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      154 => x"11",  -- bLength
      155 => x"24",  -- bDescriptorType
      156 => x"02",  -- bDescriptorSubtype
      157 => x"10",  -- bTerminalID
      158 => x"01",  -- wTerminalType
      159 => x"02",
      160 => x"00",  -- bAssocTerminal
      161 => x"09",  -- bCSourceID
      162 => x"01",  -- bNrChannels
      163 => x"04",  -- bmChannelConfig
      164 => x"00",
      165 => x"00",
      166 => x"00",
      167 => x"00",  -- iChannelNames
      168 => x"00",  -- bmControls
      169 => x"00",
      170 => x"05",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      171 => x"11",  -- bLength
      172 => x"24",  -- bDescriptorType
      173 => x"02",  -- bDescriptorSubtype
      174 => x"11",  -- bTerminalID
      175 => x"01",  -- wTerminalType
      176 => x"02",
      177 => x"00",  -- bAssocTerminal
      178 => x"09",  -- bCSourceID
      179 => x"01",  -- bNrChannels
      180 => x"04",  -- bmChannelConfig
      181 => x"00",
      182 => x"00",
      183 => x"00",
      184 => x"00",  -- iChannelNames
      185 => x"00",  -- bmControls
      186 => x"00",
      187 => x"06",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      188 => x"11",  -- bLength
      189 => x"24",  -- bDescriptorType
      190 => x"02",  -- bDescriptorSubtype
      191 => x"12",  -- bTerminalID
      192 => x"01",  -- wTerminalType
      193 => x"02",
      194 => x"00",  -- bAssocTerminal
      195 => x"09",  -- bCSourceID
      196 => x"01",  -- bNrChannels
      197 => x"04",  -- bmChannelConfig
      198 => x"00",
      199 => x"00",
      200 => x"00",
      201 => x"00",  -- iChannelNames
      202 => x"00",  -- bmControls
      203 => x"00",
      204 => x"07",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      205 => x"11",  -- bLength
      206 => x"24",  -- bDescriptorType
      207 => x"02",  -- bDescriptorSubtype
      208 => x"13",  -- bTerminalID
      209 => x"01",  -- wTerminalType
      210 => x"02",
      211 => x"00",  -- bAssocTerminal
      212 => x"09",  -- bCSourceID
      213 => x"01",  -- bNrChannels
      214 => x"04",  -- bmChannelConfig
      215 => x"00",
      216 => x"00",
      217 => x"00",
      218 => x"00",  -- iChannelNames
      219 => x"00",  -- bmControls
      220 => x"00",
      221 => x"08",  -- iTerminal
      -- Usb2UAC2SelectorUnitDesc
      222 => x"0c",  -- bLength
      223 => x"24",  -- bDescriptorType
      224 => x"05",  -- bDescriptorSubtype
      225 => x"0f",  -- bUnitID
      226 => x"05",  -- bNrInPins
      227 => x"01",  -- baSourceID
      228 => x"10",
      229 => x"11",
      230 => x"12",
      231 => x"13",
      232 => x"03",  -- bmControls
      233 => x"09",  -- iSelector
      -- Usb2UAC2MonoFeatureUnitDesc
      234 => x"0e",  -- bLength
      235 => x"24",  -- bDescriptorType
      236 => x"06",  -- bDescriptorSubtype
      237 => x"02",  -- bUnitID
      238 => x"0f",  -- bSourceID
      239 => x"0f",  -- bmaControls0
      240 => x"00",
      241 => x"00",
      242 => x"00",
      243 => x"0f",  -- bmaControls1
      244 => x"00",
      245 => x"00",
      246 => x"00",
      247 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      248 => x"0c",  -- bLength
      249 => x"24",  -- bDescriptorType
      250 => x"03",  -- bDescriptorSubtype
      251 => x"03",  -- bTerminalID
      252 => x"01",  -- wTerminalType
      253 => x"01",
      254 => x"00",  -- bAssocTerminal
      255 => x"02",  -- bSourceID
      256 => x"09",  -- bCSourceID
      257 => x"00",  -- bmControls
      258 => x"00",
      259 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      260 => x"09",  -- bLength
      261 => x"04",  -- bDescriptorType
      262 => x"03",  -- bInterfaceNumber
      263 => x"00",  -- bAlternateSetting
      264 => x"00",  -- bNumEndpoints
      265 => x"01",  -- bInterfaceClass
      266 => x"02",  -- bInterfaceSubClass
      267 => x"20",  -- bInterfaceProtocol
      268 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      269 => x"09",  -- bLength
      270 => x"04",  -- bDescriptorType
      271 => x"03",  -- bInterfaceNumber
      272 => x"01",  -- bAlternateSetting
      273 => x"01",  -- bNumEndpoints
      274 => x"01",  -- bInterfaceClass
      275 => x"02",  -- bInterfaceSubClass
      276 => x"20",  -- bInterfaceProtocol
      277 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      278 => x"10",  -- bLength
      279 => x"24",  -- bDescriptorType
      280 => x"01",  -- bDescriptorSubtype
      281 => x"03",  -- bTerminalLink
      282 => x"00",  -- bmControls
      283 => x"01",  -- bFormatType
      284 => x"01",  -- bmFormats
      285 => x"00",
      286 => x"00",
      287 => x"00",
      288 => x"01",  -- bNrChannels
      289 => x"04",  -- bmChannelConfig
      290 => x"00",
      291 => x"00",
      292 => x"00",
      293 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      294 => x"06",  -- bLength
      295 => x"24",  -- bDescriptorType
      296 => x"02",  -- bDescriptorSubtype
      297 => x"01",  -- bFormatType
      298 => x"02",  -- bSubslotSize
      299 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      300 => x"07",  -- bLength
      301 => x"05",  -- bDescriptorType
      302 => x"83",  -- bEndpointAddress
      303 => x"05",  -- bmAttributes
      304 => x"62",  -- wMaxPacketSize
      305 => x"00",
      306 => x"01",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      307 => x"08",  -- bLength
      308 => x"25",  -- bDescriptorType
      309 => x"01",  -- bDescriptorSubtype
      310 => x"00",  -- bmAttributes
      311 => x"00",  -- bmControls
      312 => x"00",  -- bLockDelayUnits
      313 => x"00",  -- wLockDelay
      314 => x"00",
      -- Usb2InterfaceAssociationDesc
      315 => x"08",  -- bLength
      316 => x"0b",  -- bDescriptorType
      317 => x"04",  -- bFirstInterface
      318 => x"02",  -- bInterfaceCount
      319 => x"02",  -- bFunctionClass
      320 => x"0d",  -- bFunctionSubClass
      321 => x"00",  -- bFunctionProtocol
      322 => x"0a",  -- iFunction
      -- Usb2InterfaceDesc
      323 => x"09",  -- bLength
      324 => x"04",  -- bDescriptorType
      325 => x"04",  -- bInterfaceNumber
      326 => x"00",  -- bAlternateSetting
      327 => x"01",  -- bNumEndpoints
      328 => x"02",  -- bInterfaceClass
      329 => x"0d",  -- bInterfaceSubClass
      330 => x"00",  -- bInterfaceProtocol
      331 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      332 => x"05",  -- bLength
      333 => x"24",  -- bDescriptorType
      334 => x"00",  -- bDescriptorSubtype
      335 => x"20",  -- bcdCDC
      336 => x"01",
      -- Usb2CDCFuncUnionDesc
      337 => x"05",  -- bLength
      338 => x"24",  -- bDescriptorType
      339 => x"06",  -- bDescriptorSubtype
      340 => x"04",  -- bControlInterface
      341 => x"05",
      -- Usb2CDCFuncEthernetDesc
      342 => x"0d",  -- bLength
      343 => x"24",  -- bDescriptorType
      344 => x"0f",  -- bDescriptorSubtype
      345 => x"0b",  -- iMACAddress
      346 => x"00",  -- bmEthernetStatistics
      347 => x"00",
      348 => x"00",
      349 => x"00",
      350 => x"ea",  -- wMaxSegmentSize
      351 => x"05",
      352 => x"20",  -- wNumberMCFilters
      353 => x"80",
      354 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      355 => x"06",  -- bLength
      356 => x"24",  -- bDescriptorType
      357 => x"1a",  -- bDescriptorSubtype
      358 => x"00",  -- bcdNcmVersion
      359 => x"01",
      360 => x"03",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      361 => x"07",  -- bLength
      362 => x"05",  -- bDescriptorType
      363 => x"85",  -- bEndpointAddress
      364 => x"03",  -- bmAttributes
      365 => x"10",  -- wMaxPacketSize
      366 => x"00",
      367 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
      368 => x"09",  -- bLength
      369 => x"04",  -- bDescriptorType
      370 => x"05",  -- bInterfaceNumber
      371 => x"00",  -- bAlternateSetting
      372 => x"00",  -- bNumEndpoints
      373 => x"0a",  -- bInterfaceClass
      374 => x"00",  -- bInterfaceSubClass
      375 => x"01",  -- bInterfaceProtocol
      376 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      377 => x"09",  -- bLength
      378 => x"04",  -- bDescriptorType
      379 => x"05",  -- bInterfaceNumber
      380 => x"01",  -- bAlternateSetting
      381 => x"02",  -- bNumEndpoints
      382 => x"0a",  -- bInterfaceClass
      383 => x"00",  -- bInterfaceSubClass
      384 => x"01",  -- bInterfaceProtocol
      385 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      386 => x"07",  -- bLength
      387 => x"05",  -- bDescriptorType
      388 => x"84",  -- bEndpointAddress
      389 => x"02",  -- bmAttributes
      390 => x"40",  -- wMaxPacketSize
      391 => x"00",
      392 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      393 => x"07",  -- bLength
      394 => x"05",  -- bDescriptorType
      395 => x"04",  -- bEndpointAddress
      396 => x"02",  -- bmAttributes
      397 => x"40",  -- wMaxPacketSize
      398 => x"00",
      399 => x"00",  -- bInterval
      -- Usb2SentinelDesc
      400 => x"02",  -- bLength
      401 => x"ff",  -- bDescriptorType
      -- Usb2DeviceDesc
      402 => x"12",  -- bLength
      403 => x"01",  -- bDescriptorType
      404 => x"00",  -- bcdUSB
      405 => x"02",
      406 => x"ef",  -- bDeviceClass
      407 => x"02",  -- bDeviceSubClass
      408 => x"01",  -- bDeviceProtocol
      409 => x"40",  -- bMaxPacketSize0
      410 => x"09",  -- idVendor
      411 => x"12",
      412 => x"01",  -- idProduct
      413 => x"00",
      414 => x"00",  -- bcdDevice
      415 => x"01",
      416 => x"00",  -- iManufacturer
      417 => x"01",  -- iProduct
      418 => x"00",  -- iSerialNumber
      419 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
      420 => x"0a",  -- bLength
      421 => x"06",  -- bDescriptorType
      422 => x"00",  -- bcdUSB
      423 => x"02",
      424 => x"ef",  -- bDeviceClass
      425 => x"02",  -- bDeviceSubClass
      426 => x"01",  -- bDeviceProtocol
      427 => x"40",  -- bMaxPacketSize0
      428 => x"01",  -- bNumConfigurations
      429 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
      430 => x"09",  -- bLength
      431 => x"02",  -- bDescriptorType
      432 => x"74",  -- wTotalLength
      433 => x"01",
      434 => x"06",  -- bNumInterfaces
      435 => x"01",  -- bConfigurationValue
      436 => x"00",  -- iConfiguration
      437 => x"a0",  -- bmAttributes
      438 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
      439 => x"08",  -- bLength
      440 => x"0b",  -- bDescriptorType
      441 => x"00",  -- bFirstInterface
      442 => x"02",  -- bInterfaceCount
      443 => x"02",  -- bFunctionClass
      444 => x"02",  -- bFunctionSubClass
      445 => x"00",  -- bFunctionProtocol
      446 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
      447 => x"09",  -- bLength
      448 => x"04",  -- bDescriptorType
      449 => x"00",  -- bInterfaceNumber
      450 => x"00",  -- bAlternateSetting
      451 => x"01",  -- bNumEndpoints
      452 => x"02",  -- bInterfaceClass
      453 => x"02",  -- bInterfaceSubClass
      454 => x"00",  -- bInterfaceProtocol
      455 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      456 => x"05",  -- bLength
      457 => x"24",  -- bDescriptorType
      458 => x"00",  -- bDescriptorSubtype
      459 => x"20",  -- bcdCDC
      460 => x"01",
      -- Usb2CDCFuncCallManagementDesc
      461 => x"05",  -- bLength
      462 => x"24",  -- bDescriptorType
      463 => x"01",  -- bDescriptorSubtype
      464 => x"00",  -- bmCapabilities
      465 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
      466 => x"04",  -- bLength
      467 => x"24",  -- bDescriptorType
      468 => x"02",  -- bDescriptorSubtype
      469 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
      470 => x"05",  -- bLength
      471 => x"24",  -- bDescriptorType
      472 => x"06",  -- bDescriptorSubtype
      473 => x"00",  -- bControlInterface
      474 => x"01",
      -- Usb2EndpointDesc
      475 => x"07",  -- bLength
      476 => x"05",  -- bDescriptorType
      477 => x"82",  -- bEndpointAddress
      478 => x"03",  -- bmAttributes
      479 => x"08",  -- wMaxPacketSize
      480 => x"00",
      481 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      482 => x"09",  -- bLength
      483 => x"04",  -- bDescriptorType
      484 => x"01",  -- bInterfaceNumber
      485 => x"00",  -- bAlternateSetting
      486 => x"02",  -- bNumEndpoints
      487 => x"0a",  -- bInterfaceClass
      488 => x"00",  -- bInterfaceSubClass
      489 => x"00",  -- bInterfaceProtocol
      490 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      491 => x"07",  -- bLength
      492 => x"05",  -- bDescriptorType
      493 => x"81",  -- bEndpointAddress
      494 => x"02",  -- bmAttributes
      495 => x"00",  -- wMaxPacketSize
      496 => x"02",
      497 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      498 => x"07",  -- bLength
      499 => x"05",  -- bDescriptorType
      500 => x"01",  -- bEndpointAddress
      501 => x"02",  -- bmAttributes
      502 => x"00",  -- wMaxPacketSize
      503 => x"02",
      504 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      505 => x"08",  -- bLength
      506 => x"0b",  -- bDescriptorType
      507 => x"02",  -- bFirstInterface
      508 => x"02",  -- bInterfaceCount
      509 => x"01",  -- bFunctionClass
      510 => x"00",  -- bFunctionSubClass
      511 => x"20",  -- bFunctionProtocol
      512 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      513 => x"09",  -- bLength
      514 => x"04",  -- bDescriptorType
      515 => x"02",  -- bInterfaceNumber
      516 => x"00",  -- bAlternateSetting
      517 => x"00",  -- bNumEndpoints
      518 => x"01",  -- bInterfaceClass
      519 => x"01",  -- bInterfaceSubClass
      520 => x"20",  -- bInterfaceProtocol
      521 => x"00",  -- iInterface
      -- Usb2UAC2FuncHeaderDesc
      522 => x"09",  -- bLength
      523 => x"24",  -- bDescriptorType
      524 => x"01",  -- bDescriptorSubtype
      525 => x"00",  -- bcdADC
      526 => x"02",
      527 => x"03",  -- bCategory
      528 => x"8c",  -- wTotalLength
      529 => x"00",
      530 => x"00",  -- bmControls
      -- Usb2UAC2ClockSourceDesc
      531 => x"08",  -- bLength
      532 => x"24",  -- bDescriptorType
      533 => x"0a",  -- bDescriptorSubtype
      534 => x"09",  -- bClockID
      535 => x"00",  -- bmAttributes
      536 => x"01",  -- bmControls
      537 => x"00",  -- bAssocTerminal
      538 => x"00",  -- iClockSource
      -- Usb2UAC2InputTerminalDesc
      539 => x"11",  -- bLength
      540 => x"24",  -- bDescriptorType
      541 => x"02",  -- bDescriptorSubtype
      542 => x"01",  -- bTerminalID
      543 => x"01",  -- wTerminalType
      544 => x"02",
      545 => x"00",  -- bAssocTerminal
      546 => x"09",  -- bCSourceID
      547 => x"01",  -- bNrChannels
      548 => x"04",  -- bmChannelConfig
      549 => x"00",
      550 => x"00",
      551 => x"00",
      552 => x"00",  -- iChannelNames
      553 => x"00",  -- bmControls
      554 => x"00",
      555 => x"04",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      556 => x"11",  -- bLength
      557 => x"24",  -- bDescriptorType
      558 => x"02",  -- bDescriptorSubtype
      559 => x"10",  -- bTerminalID
      560 => x"01",  -- wTerminalType
      561 => x"02",
      562 => x"00",  -- bAssocTerminal
      563 => x"09",  -- bCSourceID
      564 => x"01",  -- bNrChannels
      565 => x"04",  -- bmChannelConfig
      566 => x"00",
      567 => x"00",
      568 => x"00",
      569 => x"00",  -- iChannelNames
      570 => x"00",  -- bmControls
      571 => x"00",
      572 => x"05",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      573 => x"11",  -- bLength
      574 => x"24",  -- bDescriptorType
      575 => x"02",  -- bDescriptorSubtype
      576 => x"11",  -- bTerminalID
      577 => x"01",  -- wTerminalType
      578 => x"02",
      579 => x"00",  -- bAssocTerminal
      580 => x"09",  -- bCSourceID
      581 => x"01",  -- bNrChannels
      582 => x"04",  -- bmChannelConfig
      583 => x"00",
      584 => x"00",
      585 => x"00",
      586 => x"00",  -- iChannelNames
      587 => x"00",  -- bmControls
      588 => x"00",
      589 => x"06",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      590 => x"11",  -- bLength
      591 => x"24",  -- bDescriptorType
      592 => x"02",  -- bDescriptorSubtype
      593 => x"12",  -- bTerminalID
      594 => x"01",  -- wTerminalType
      595 => x"02",
      596 => x"00",  -- bAssocTerminal
      597 => x"09",  -- bCSourceID
      598 => x"01",  -- bNrChannels
      599 => x"04",  -- bmChannelConfig
      600 => x"00",
      601 => x"00",
      602 => x"00",
      603 => x"00",  -- iChannelNames
      604 => x"00",  -- bmControls
      605 => x"00",
      606 => x"07",  -- iTerminal
      -- Usb2UAC2InputTerminalDesc
      607 => x"11",  -- bLength
      608 => x"24",  -- bDescriptorType
      609 => x"02",  -- bDescriptorSubtype
      610 => x"13",  -- bTerminalID
      611 => x"01",  -- wTerminalType
      612 => x"02",
      613 => x"00",  -- bAssocTerminal
      614 => x"09",  -- bCSourceID
      615 => x"01",  -- bNrChannels
      616 => x"04",  -- bmChannelConfig
      617 => x"00",
      618 => x"00",
      619 => x"00",
      620 => x"00",  -- iChannelNames
      621 => x"00",  -- bmControls
      622 => x"00",
      623 => x"08",  -- iTerminal
      -- Usb2UAC2SelectorUnitDesc
      624 => x"0c",  -- bLength
      625 => x"24",  -- bDescriptorType
      626 => x"05",  -- bDescriptorSubtype
      627 => x"0f",  -- bUnitID
      628 => x"05",  -- bNrInPins
      629 => x"01",  -- baSourceID
      630 => x"10",
      631 => x"11",
      632 => x"12",
      633 => x"13",
      634 => x"03",  -- bmControls
      635 => x"09",  -- iSelector
      -- Usb2UAC2MonoFeatureUnitDesc
      636 => x"0e",  -- bLength
      637 => x"24",  -- bDescriptorType
      638 => x"06",  -- bDescriptorSubtype
      639 => x"02",  -- bUnitID
      640 => x"0f",  -- bSourceID
      641 => x"0f",  -- bmaControls0
      642 => x"00",
      643 => x"00",
      644 => x"00",
      645 => x"0f",  -- bmaControls1
      646 => x"00",
      647 => x"00",
      648 => x"00",
      649 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      650 => x"0c",  -- bLength
      651 => x"24",  -- bDescriptorType
      652 => x"03",  -- bDescriptorSubtype
      653 => x"03",  -- bTerminalID
      654 => x"01",  -- wTerminalType
      655 => x"01",
      656 => x"00",  -- bAssocTerminal
      657 => x"02",  -- bSourceID
      658 => x"09",  -- bCSourceID
      659 => x"00",  -- bmControls
      660 => x"00",
      661 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      662 => x"09",  -- bLength
      663 => x"04",  -- bDescriptorType
      664 => x"03",  -- bInterfaceNumber
      665 => x"00",  -- bAlternateSetting
      666 => x"00",  -- bNumEndpoints
      667 => x"01",  -- bInterfaceClass
      668 => x"02",  -- bInterfaceSubClass
      669 => x"20",  -- bInterfaceProtocol
      670 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      671 => x"09",  -- bLength
      672 => x"04",  -- bDescriptorType
      673 => x"03",  -- bInterfaceNumber
      674 => x"01",  -- bAlternateSetting
      675 => x"01",  -- bNumEndpoints
      676 => x"01",  -- bInterfaceClass
      677 => x"02",  -- bInterfaceSubClass
      678 => x"20",  -- bInterfaceProtocol
      679 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      680 => x"10",  -- bLength
      681 => x"24",  -- bDescriptorType
      682 => x"01",  -- bDescriptorSubtype
      683 => x"03",  -- bTerminalLink
      684 => x"00",  -- bmControls
      685 => x"01",  -- bFormatType
      686 => x"01",  -- bmFormats
      687 => x"00",
      688 => x"00",
      689 => x"00",
      690 => x"01",  -- bNrChannels
      691 => x"04",  -- bmChannelConfig
      692 => x"00",
      693 => x"00",
      694 => x"00",
      695 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      696 => x"06",  -- bLength
      697 => x"24",  -- bDescriptorType
      698 => x"02",  -- bDescriptorSubtype
      699 => x"01",  -- bFormatType
      700 => x"02",  -- bSubslotSize
      701 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      702 => x"07",  -- bLength
      703 => x"05",  -- bDescriptorType
      704 => x"83",  -- bEndpointAddress
      705 => x"05",  -- bmAttributes
      706 => x"62",  -- wMaxPacketSize
      707 => x"00",
      708 => x"04",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      709 => x"08",  -- bLength
      710 => x"25",  -- bDescriptorType
      711 => x"01",  -- bDescriptorSubtype
      712 => x"00",  -- bmAttributes
      713 => x"00",  -- bmControls
      714 => x"00",  -- bLockDelayUnits
      715 => x"00",  -- wLockDelay
      716 => x"00",
      -- Usb2InterfaceAssociationDesc
      717 => x"08",  -- bLength
      718 => x"0b",  -- bDescriptorType
      719 => x"04",  -- bFirstInterface
      720 => x"02",  -- bInterfaceCount
      721 => x"02",  -- bFunctionClass
      722 => x"0d",  -- bFunctionSubClass
      723 => x"00",  -- bFunctionProtocol
      724 => x"0a",  -- iFunction
      -- Usb2InterfaceDesc
      725 => x"09",  -- bLength
      726 => x"04",  -- bDescriptorType
      727 => x"04",  -- bInterfaceNumber
      728 => x"00",  -- bAlternateSetting
      729 => x"01",  -- bNumEndpoints
      730 => x"02",  -- bInterfaceClass
      731 => x"0d",  -- bInterfaceSubClass
      732 => x"00",  -- bInterfaceProtocol
      733 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      734 => x"05",  -- bLength
      735 => x"24",  -- bDescriptorType
      736 => x"00",  -- bDescriptorSubtype
      737 => x"20",  -- bcdCDC
      738 => x"01",
      -- Usb2CDCFuncUnionDesc
      739 => x"05",  -- bLength
      740 => x"24",  -- bDescriptorType
      741 => x"06",  -- bDescriptorSubtype
      742 => x"04",  -- bControlInterface
      743 => x"05",
      -- Usb2CDCFuncEthernetDesc
      744 => x"0d",  -- bLength
      745 => x"24",  -- bDescriptorType
      746 => x"0f",  -- bDescriptorSubtype
      747 => x"0b",  -- iMACAddress
      748 => x"00",  -- bmEthernetStatistics
      749 => x"00",
      750 => x"00",
      751 => x"00",
      752 => x"ea",  -- wMaxSegmentSize
      753 => x"05",
      754 => x"20",  -- wNumberMCFilters
      755 => x"80",
      756 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      757 => x"06",  -- bLength
      758 => x"24",  -- bDescriptorType
      759 => x"1a",  -- bDescriptorSubtype
      760 => x"00",  -- bcdNcmVersion
      761 => x"01",
      762 => x"03",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      763 => x"07",  -- bLength
      764 => x"05",  -- bDescriptorType
      765 => x"85",  -- bEndpointAddress
      766 => x"03",  -- bmAttributes
      767 => x"10",  -- wMaxPacketSize
      768 => x"00",
      769 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      770 => x"09",  -- bLength
      771 => x"04",  -- bDescriptorType
      772 => x"05",  -- bInterfaceNumber
      773 => x"00",  -- bAlternateSetting
      774 => x"00",  -- bNumEndpoints
      775 => x"0a",  -- bInterfaceClass
      776 => x"00",  -- bInterfaceSubClass
      777 => x"01",  -- bInterfaceProtocol
      778 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      779 => x"09",  -- bLength
      780 => x"04",  -- bDescriptorType
      781 => x"05",  -- bInterfaceNumber
      782 => x"01",  -- bAlternateSetting
      783 => x"02",  -- bNumEndpoints
      784 => x"0a",  -- bInterfaceClass
      785 => x"00",  -- bInterfaceSubClass
      786 => x"01",  -- bInterfaceProtocol
      787 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      788 => x"07",  -- bLength
      789 => x"05",  -- bDescriptorType
      790 => x"84",  -- bEndpointAddress
      791 => x"02",  -- bmAttributes
      792 => x"00",  -- wMaxPacketSize
      793 => x"02",
      794 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      795 => x"07",  -- bLength
      796 => x"05",  -- bDescriptorType
      797 => x"04",  -- bEndpointAddress
      798 => x"02",  -- bmAttributes
      799 => x"00",  -- wMaxPacketSize
      800 => x"02",
      801 => x"00",  -- bInterval
      -- Usb2StringDesc
      802 => x"04",  -- bLength
      803 => x"03",  -- bDescriptorType
      804 => x"09",  -- langID 0x0409
      805 => x"04",
      -- Usb2StringDesc
      806 => x"46",  -- bLength
      807 => x"03",  -- bDescriptorType
      808 => x"54",  -- T
      809 => x"00",
      810 => x"69",  -- i
      811 => x"00",
      812 => x"6c",  -- l
      813 => x"00",
      814 => x"6c",  -- l
      815 => x"00",
      816 => x"27",  -- '
      817 => x"00",
      818 => x"73",  -- s
      819 => x"00",
      820 => x"20",  --  
      821 => x"00",
      822 => x"4d",  -- M
      823 => x"00",
      824 => x"65",  -- e
      825 => x"00",
      826 => x"63",  -- c
      827 => x"00",
      828 => x"61",  -- a
      829 => x"00",
      830 => x"74",  -- t
      831 => x"00",
      832 => x"69",  -- i
      833 => x"00",
      834 => x"63",  -- c
      835 => x"00",
      836 => x"61",  -- a
      837 => x"00",
      838 => x"20",  --  
      839 => x"00",
      840 => x"55",  -- U
      841 => x"00",
      842 => x"53",  -- S
      843 => x"00",
      844 => x"42",  -- B
      845 => x"00",
      846 => x"20",  --  
      847 => x"00",
      848 => x"45",  -- E
      849 => x"00",
      850 => x"78",  -- x
      851 => x"00",
      852 => x"61",  -- a
      853 => x"00",
      854 => x"6d",  -- m
      855 => x"00",
      856 => x"70",  -- p
      857 => x"00",
      858 => x"6c",  -- l
      859 => x"00",
      860 => x"65",  -- e
      861 => x"00",
      862 => x"20",  --  
      863 => x"00",
      864 => x"44",  -- D
      865 => x"00",
      866 => x"65",  -- e
      867 => x"00",
      868 => x"76",  -- v
      869 => x"00",
      870 => x"69",  -- i
      871 => x"00",
      872 => x"63",  -- c
      873 => x"00",
      874 => x"65",  -- e
      875 => x"00",
      -- Usb2StringDesc
      876 => x"1a",  -- bLength
      877 => x"03",  -- bDescriptorType
      878 => x"4d",  -- M
      879 => x"00",
      880 => x"65",  -- e
      881 => x"00",
      882 => x"63",  -- c
      883 => x"00",
      884 => x"61",  -- a
      885 => x"00",
      886 => x"74",  -- t
      887 => x"00",
      888 => x"69",  -- i
      889 => x"00",
      890 => x"63",  -- c
      891 => x"00",
      892 => x"61",  -- a
      893 => x"00",
      894 => x"20",  --  
      895 => x"00",
      896 => x"41",  -- A
      897 => x"00",
      898 => x"43",  -- C
      899 => x"00",
      900 => x"4d",  -- M
      901 => x"00",
      -- Usb2StringDesc
      902 => x"32",  -- bLength
      903 => x"03",  -- bDescriptorType
      904 => x"4d",  -- M
      905 => x"00",
      906 => x"65",  -- e
      907 => x"00",
      908 => x"63",  -- c
      909 => x"00",
      910 => x"61",  -- a
      911 => x"00",
      912 => x"74",  -- t
      913 => x"00",
      914 => x"69",  -- i
      915 => x"00",
      916 => x"63",  -- c
      917 => x"00",
      918 => x"61",  -- a
      919 => x"00",
      920 => x"20",  --  
      921 => x"00",
      922 => x"4d",  -- M
      923 => x"00",
      924 => x"69",  -- i
      925 => x"00",
      926 => x"63",  -- c
      927 => x"00",
      928 => x"72",  -- r
      929 => x"00",
      930 => x"6f",  -- o
      931 => x"00",
      932 => x"70",  -- p
      933 => x"00",
      934 => x"68",  -- h
      935 => x"00",
      936 => x"6f",  -- o
      937 => x"00",
      938 => x"6e",  -- n
      939 => x"00",
      940 => x"65",  -- e
      941 => x"00",
      942 => x"20",  --  
      943 => x"00",
      944 => x"54",  -- T
      945 => x"00",
      946 => x"65",  -- e
      947 => x"00",
      948 => x"73",  -- s
      949 => x"00",
      950 => x"74",  -- t
      951 => x"00",
      -- Usb2StringDesc
      952 => x"12",  -- bLength
      953 => x"03",  -- bDescriptorType
      954 => x"53",  -- S
      955 => x"00",
      956 => x"69",  -- i
      957 => x"00",
      958 => x"6e",  -- n
      959 => x"00",
      960 => x"2d",  -- -
      961 => x"00",
      962 => x"54",  -- T
      963 => x"00",
      964 => x"65",  -- e
      965 => x"00",
      966 => x"73",  -- s
      967 => x"00",
      968 => x"74",  -- t
      969 => x"00",
      -- Usb2StringDesc
      970 => x"12",  -- bLength
      971 => x"03",  -- bDescriptorType
      972 => x"43",  -- C
      973 => x"00",
      974 => x"49",  -- I
      975 => x"00",
      976 => x"43",  -- C
      977 => x"00",
      978 => x"2d",  -- -
      979 => x"00",
      980 => x"31",  -- 1
      981 => x"00",
      982 => x"73",  -- s
      983 => x"00",
      984 => x"74",  -- t
      985 => x"00",
      986 => x"67",  -- g
      987 => x"00",
      -- Usb2StringDesc
      988 => x"12",  -- bLength
      989 => x"03",  -- bDescriptorType
      990 => x"43",  -- C
      991 => x"00",
      992 => x"49",  -- I
      993 => x"00",
      994 => x"43",  -- C
      995 => x"00",
      996 => x"2d",  -- -
      997 => x"00",
      998 => x"32",  -- 2
      999 => x"00",
      1000 => x"73",  -- s
      1001 => x"00",
      1002 => x"74",  -- t
      1003 => x"00",
      1004 => x"67",  -- g
      1005 => x"00",
      -- Usb2StringDesc
      1006 => x"12",  -- bLength
      1007 => x"03",  -- bDescriptorType
      1008 => x"43",  -- C
      1009 => x"00",
      1010 => x"49",  -- I
      1011 => x"00",
      1012 => x"43",  -- C
      1013 => x"00",
      1014 => x"2d",  -- -
      1015 => x"00",
      1016 => x"33",  -- 3
      1017 => x"00",
      1018 => x"73",  -- s
      1019 => x"00",
      1020 => x"74",  -- t
      1021 => x"00",
      1022 => x"67",  -- g
      1023 => x"00",
      -- Usb2StringDesc
      1024 => x"12",  -- bLength
      1025 => x"03",  -- bDescriptorType
      1026 => x"43",  -- C
      1027 => x"00",
      1028 => x"49",  -- I
      1029 => x"00",
      1030 => x"43",  -- C
      1031 => x"00",
      1032 => x"2d",  -- -
      1033 => x"00",
      1034 => x"34",  -- 4
      1035 => x"00",
      1036 => x"73",  -- s
      1037 => x"00",
      1038 => x"74",  -- t
      1039 => x"00",
      1040 => x"67",  -- g
      1041 => x"00",
      -- Usb2StringDesc
      1042 => x"2a",  -- bLength
      1043 => x"03",  -- bDescriptorType
      1044 => x"4d",  -- M
      1045 => x"00",
      1046 => x"65",  -- e
      1047 => x"00",
      1048 => x"63",  -- c
      1049 => x"00",
      1050 => x"61",  -- a
      1051 => x"00",
      1052 => x"74",  -- t
      1053 => x"00",
      1054 => x"69",  -- i
      1055 => x"00",
      1056 => x"63",  -- c
      1057 => x"00",
      1058 => x"61",  -- a
      1059 => x"00",
      1060 => x"20",  --  
      1061 => x"00",
      1062 => x"4d",  -- M
      1063 => x"00",
      1064 => x"69",  -- i
      1065 => x"00",
      1066 => x"63",  -- c
      1067 => x"00",
      1068 => x"20",  --  
      1069 => x"00",
      1070 => x"43",  -- C
      1071 => x"00",
      1072 => x"61",  -- a
      1073 => x"00",
      1074 => x"70",  -- p
      1075 => x"00",
      1076 => x"74",  -- t
      1077 => x"00",
      1078 => x"75",  -- u
      1079 => x"00",
      1080 => x"72",  -- r
      1081 => x"00",
      1082 => x"65",  -- e
      1083 => x"00",
      -- Usb2StringDesc
      1084 => x"3a",  -- bLength
      1085 => x"03",  -- bDescriptorType
      1086 => x"54",  -- T
      1087 => x"00",
      1088 => x"69",  -- i
      1089 => x"00",
      1090 => x"63",  -- c
      1091 => x"00",
      1092 => x"2d",  -- -
      1093 => x"00",
      1094 => x"4e",  -- N
      1095 => x"00",
      1096 => x"69",  -- i
      1097 => x"00",
      1098 => x"63",  -- c
      1099 => x"00",
      1100 => x"20",  --  
      1101 => x"00",
      1102 => x"50",  -- P
      1103 => x"00",
      1104 => x"54",  -- T
      1105 => x"00",
      1106 => x"50",  -- P
      1107 => x"00",
      1108 => x"20",  --  
      1109 => x"00",
      1110 => x"45",  -- E
      1111 => x"00",
      1112 => x"74",  -- t
      1113 => x"00",
      1114 => x"68",  -- h
      1115 => x"00",
      1116 => x"65",  -- e
      1117 => x"00",
      1118 => x"72",  -- r
      1119 => x"00",
      1120 => x"6e",  -- n
      1121 => x"00",
      1122 => x"65",  -- e
      1123 => x"00",
      1124 => x"74",  -- t
      1125 => x"00",
      1126 => x"20",  --  
      1127 => x"00",
      1128 => x"41",  -- A
      1129 => x"00",
      1130 => x"64",  -- d
      1131 => x"00",
      1132 => x"61",  -- a
      1133 => x"00",
      1134 => x"70",  -- p
      1135 => x"00",
      1136 => x"74",  -- t
      1137 => x"00",
      1138 => x"65",  -- e
      1139 => x"00",
      1140 => x"72",  -- r
      1141 => x"00",
      -- Usb2StringDesc
      1142 => x"1a",  -- bLength
      1143 => x"03",  -- bDescriptorType
      1144 => x"30",  -- 0
      1145 => x"00",
      1146 => x"32",  -- 2
      1147 => x"00",
      1148 => x"64",  -- d
      1149 => x"00",
      1150 => x"65",  -- e
      1151 => x"00",
      1152 => x"61",  -- a
      1153 => x"00",
      1154 => x"64",  -- d
      1155 => x"00",
      1156 => x"62",  -- b
      1157 => x"00",
      1158 => x"65",  -- e
      1159 => x"00",
      1160 => x"65",  -- e
      1161 => x"00",
      1162 => x"66",  -- f
      1163 => x"00",
      1164 => x"33",  -- 3
      1165 => x"00",
      1166 => x"31",  -- 1
      1167 => x"00",
      -- Usb2SentinelDesc
      1168 => x"02",  -- bLength
      1169 => x"ff"   -- bDescriptorType
      );
   begin
      return c;
   end function usb2AppGetDescriptors;

   constant USB2_APP_DESCRIPTORS_C : Usb2ByteArray := usb2AppGetDescriptors;

end package body Usb2AppCfgPkg;
