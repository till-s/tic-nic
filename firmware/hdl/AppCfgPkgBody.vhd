-- Copyright Till Straumann, 2023. Licensed under the EUPL-1.2 or later.
-- You may obtain a copy of the license at
--   https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
-- This notice must not be removed.

-- THIS FILE WAS AUTOMATICALLY GENERATED; DO NOT EDIT!

-- Generated from: 'tic_nic_nosel.yaml':
--
-- deviceDesc:
--   configurationDesc:
--     functionNCM:
--       enabled: true
--       iFunction: Mecatica NCM
--       iMACAddress: 02deadbeef31
--       numMulticastFilters: 32800
--     functionUAC2Input:
--       enabled: true
--       iFunction: Mecatica UAC2 Microphone
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
       30 => x"24",  -- wTotalLength
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
      126 => x"3c",  -- wTotalLength
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
      153 => x"00",  -- iTerminal
      -- Usb2UAC2MonoFeatureUnitDesc
      154 => x"0e",  -- bLength
      155 => x"24",  -- bDescriptorType
      156 => x"06",  -- bDescriptorSubtype
      157 => x"02",  -- bUnitID
      158 => x"01",  -- bSourceID
      159 => x"0f",  -- bmaControls0
      160 => x"00",
      161 => x"00",
      162 => x"00",
      163 => x"0f",  -- bmaControls1
      164 => x"00",
      165 => x"00",
      166 => x"00",
      167 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      168 => x"0c",  -- bLength
      169 => x"24",  -- bDescriptorType
      170 => x"03",  -- bDescriptorSubtype
      171 => x"03",  -- bTerminalID
      172 => x"01",  -- wTerminalType
      173 => x"01",
      174 => x"00",  -- bAssocTerminal
      175 => x"02",  -- bSourceID
      176 => x"09",  -- bCSourceID
      177 => x"00",  -- bmControls
      178 => x"00",
      179 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      180 => x"09",  -- bLength
      181 => x"04",  -- bDescriptorType
      182 => x"03",  -- bInterfaceNumber
      183 => x"00",  -- bAlternateSetting
      184 => x"00",  -- bNumEndpoints
      185 => x"01",  -- bInterfaceClass
      186 => x"02",  -- bInterfaceSubClass
      187 => x"20",  -- bInterfaceProtocol
      188 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      189 => x"09",  -- bLength
      190 => x"04",  -- bDescriptorType
      191 => x"03",  -- bInterfaceNumber
      192 => x"01",  -- bAlternateSetting
      193 => x"01",  -- bNumEndpoints
      194 => x"01",  -- bInterfaceClass
      195 => x"02",  -- bInterfaceSubClass
      196 => x"20",  -- bInterfaceProtocol
      197 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      198 => x"10",  -- bLength
      199 => x"24",  -- bDescriptorType
      200 => x"01",  -- bDescriptorSubtype
      201 => x"03",  -- bTerminalLink
      202 => x"00",  -- bmControls
      203 => x"01",  -- bFormatType
      204 => x"01",  -- bmFormats
      205 => x"00",
      206 => x"00",
      207 => x"00",
      208 => x"01",  -- bNrChannels
      209 => x"04",  -- bmChannelConfig
      210 => x"00",
      211 => x"00",
      212 => x"00",
      213 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      214 => x"06",  -- bLength
      215 => x"24",  -- bDescriptorType
      216 => x"02",  -- bDescriptorSubtype
      217 => x"01",  -- bFormatType
      218 => x"02",  -- bSubslotSize
      219 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      220 => x"07",  -- bLength
      221 => x"05",  -- bDescriptorType
      222 => x"83",  -- bEndpointAddress
      223 => x"05",  -- bmAttributes
      224 => x"62",  -- wMaxPacketSize
      225 => x"00",
      226 => x"01",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      227 => x"08",  -- bLength
      228 => x"25",  -- bDescriptorType
      229 => x"01",  -- bDescriptorSubtype
      230 => x"00",  -- bmAttributes
      231 => x"00",  -- bmControls
      232 => x"00",  -- bLockDelayUnits
      233 => x"00",  -- wLockDelay
      234 => x"00",
      -- Usb2InterfaceAssociationDesc
      235 => x"08",  -- bLength
      236 => x"0b",  -- bDescriptorType
      237 => x"04",  -- bFirstInterface
      238 => x"02",  -- bInterfaceCount
      239 => x"02",  -- bFunctionClass
      240 => x"0d",  -- bFunctionSubClass
      241 => x"00",  -- bFunctionProtocol
      242 => x"04",  -- iFunction
      -- Usb2InterfaceDesc
      243 => x"09",  -- bLength
      244 => x"04",  -- bDescriptorType
      245 => x"04",  -- bInterfaceNumber
      246 => x"00",  -- bAlternateSetting
      247 => x"01",  -- bNumEndpoints
      248 => x"02",  -- bInterfaceClass
      249 => x"0d",  -- bInterfaceSubClass
      250 => x"00",  -- bInterfaceProtocol
      251 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      252 => x"05",  -- bLength
      253 => x"24",  -- bDescriptorType
      254 => x"00",  -- bDescriptorSubtype
      255 => x"20",  -- bcdCDC
      256 => x"01",
      -- Usb2CDCFuncUnionDesc
      257 => x"05",  -- bLength
      258 => x"24",  -- bDescriptorType
      259 => x"06",  -- bDescriptorSubtype
      260 => x"04",  -- bControlInterface
      261 => x"05",
      -- Usb2CDCFuncEthernetDesc
      262 => x"0d",  -- bLength
      263 => x"24",  -- bDescriptorType
      264 => x"0f",  -- bDescriptorSubtype
      265 => x"05",  -- iMACAddress
      266 => x"00",  -- bmEthernetStatistics
      267 => x"00",
      268 => x"00",
      269 => x"00",
      270 => x"ea",  -- wMaxSegmentSize
      271 => x"05",
      272 => x"20",  -- wNumberMCFilters
      273 => x"80",
      274 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      275 => x"06",  -- bLength
      276 => x"24",  -- bDescriptorType
      277 => x"1a",  -- bDescriptorSubtype
      278 => x"00",  -- bcdNcmVersion
      279 => x"01",
      280 => x"01",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      281 => x"07",  -- bLength
      282 => x"05",  -- bDescriptorType
      283 => x"85",  -- bEndpointAddress
      284 => x"03",  -- bmAttributes
      285 => x"10",  -- wMaxPacketSize
      286 => x"00",
      287 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
      288 => x"09",  -- bLength
      289 => x"04",  -- bDescriptorType
      290 => x"05",  -- bInterfaceNumber
      291 => x"00",  -- bAlternateSetting
      292 => x"00",  -- bNumEndpoints
      293 => x"0a",  -- bInterfaceClass
      294 => x"00",  -- bInterfaceSubClass
      295 => x"01",  -- bInterfaceProtocol
      296 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      297 => x"09",  -- bLength
      298 => x"04",  -- bDescriptorType
      299 => x"05",  -- bInterfaceNumber
      300 => x"01",  -- bAlternateSetting
      301 => x"02",  -- bNumEndpoints
      302 => x"0a",  -- bInterfaceClass
      303 => x"00",  -- bInterfaceSubClass
      304 => x"01",  -- bInterfaceProtocol
      305 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      306 => x"07",  -- bLength
      307 => x"05",  -- bDescriptorType
      308 => x"84",  -- bEndpointAddress
      309 => x"02",  -- bmAttributes
      310 => x"40",  -- wMaxPacketSize
      311 => x"00",
      312 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      313 => x"07",  -- bLength
      314 => x"05",  -- bDescriptorType
      315 => x"04",  -- bEndpointAddress
      316 => x"02",  -- bmAttributes
      317 => x"40",  -- wMaxPacketSize
      318 => x"00",
      319 => x"00",  -- bInterval
      -- Usb2SentinelDesc
      320 => x"02",  -- bLength
      321 => x"ff",  -- bDescriptorType
      -- Usb2DeviceDesc
      322 => x"12",  -- bLength
      323 => x"01",  -- bDescriptorType
      324 => x"00",  -- bcdUSB
      325 => x"02",
      326 => x"ef",  -- bDeviceClass
      327 => x"02",  -- bDeviceSubClass
      328 => x"01",  -- bDeviceProtocol
      329 => x"40",  -- bMaxPacketSize0
      330 => x"09",  -- idVendor
      331 => x"12",
      332 => x"01",  -- idProduct
      333 => x"00",
      334 => x"00",  -- bcdDevice
      335 => x"01",
      336 => x"00",  -- iManufacturer
      337 => x"01",  -- iProduct
      338 => x"00",  -- iSerialNumber
      339 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
      340 => x"0a",  -- bLength
      341 => x"06",  -- bDescriptorType
      342 => x"00",  -- bcdUSB
      343 => x"02",
      344 => x"ef",  -- bDeviceClass
      345 => x"02",  -- bDeviceSubClass
      346 => x"01",  -- bDeviceProtocol
      347 => x"40",  -- bMaxPacketSize0
      348 => x"01",  -- bNumConfigurations
      349 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
      350 => x"09",  -- bLength
      351 => x"02",  -- bDescriptorType
      352 => x"24",  -- wTotalLength
      353 => x"01",
      354 => x"06",  -- bNumInterfaces
      355 => x"01",  -- bConfigurationValue
      356 => x"00",  -- iConfiguration
      357 => x"a0",  -- bmAttributes
      358 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
      359 => x"08",  -- bLength
      360 => x"0b",  -- bDescriptorType
      361 => x"00",  -- bFirstInterface
      362 => x"02",  -- bInterfaceCount
      363 => x"02",  -- bFunctionClass
      364 => x"02",  -- bFunctionSubClass
      365 => x"00",  -- bFunctionProtocol
      366 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
      367 => x"09",  -- bLength
      368 => x"04",  -- bDescriptorType
      369 => x"00",  -- bInterfaceNumber
      370 => x"00",  -- bAlternateSetting
      371 => x"01",  -- bNumEndpoints
      372 => x"02",  -- bInterfaceClass
      373 => x"02",  -- bInterfaceSubClass
      374 => x"00",  -- bInterfaceProtocol
      375 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      376 => x"05",  -- bLength
      377 => x"24",  -- bDescriptorType
      378 => x"00",  -- bDescriptorSubtype
      379 => x"20",  -- bcdCDC
      380 => x"01",
      -- Usb2CDCFuncCallManagementDesc
      381 => x"05",  -- bLength
      382 => x"24",  -- bDescriptorType
      383 => x"01",  -- bDescriptorSubtype
      384 => x"00",  -- bmCapabilities
      385 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
      386 => x"04",  -- bLength
      387 => x"24",  -- bDescriptorType
      388 => x"02",  -- bDescriptorSubtype
      389 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
      390 => x"05",  -- bLength
      391 => x"24",  -- bDescriptorType
      392 => x"06",  -- bDescriptorSubtype
      393 => x"00",  -- bControlInterface
      394 => x"01",
      -- Usb2EndpointDesc
      395 => x"07",  -- bLength
      396 => x"05",  -- bDescriptorType
      397 => x"82",  -- bEndpointAddress
      398 => x"03",  -- bmAttributes
      399 => x"08",  -- wMaxPacketSize
      400 => x"00",
      401 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      402 => x"09",  -- bLength
      403 => x"04",  -- bDescriptorType
      404 => x"01",  -- bInterfaceNumber
      405 => x"00",  -- bAlternateSetting
      406 => x"02",  -- bNumEndpoints
      407 => x"0a",  -- bInterfaceClass
      408 => x"00",  -- bInterfaceSubClass
      409 => x"00",  -- bInterfaceProtocol
      410 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      411 => x"07",  -- bLength
      412 => x"05",  -- bDescriptorType
      413 => x"81",  -- bEndpointAddress
      414 => x"02",  -- bmAttributes
      415 => x"00",  -- wMaxPacketSize
      416 => x"02",
      417 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      418 => x"07",  -- bLength
      419 => x"05",  -- bDescriptorType
      420 => x"01",  -- bEndpointAddress
      421 => x"02",  -- bmAttributes
      422 => x"00",  -- wMaxPacketSize
      423 => x"02",
      424 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      425 => x"08",  -- bLength
      426 => x"0b",  -- bDescriptorType
      427 => x"02",  -- bFirstInterface
      428 => x"02",  -- bInterfaceCount
      429 => x"01",  -- bFunctionClass
      430 => x"00",  -- bFunctionSubClass
      431 => x"20",  -- bFunctionProtocol
      432 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      433 => x"09",  -- bLength
      434 => x"04",  -- bDescriptorType
      435 => x"02",  -- bInterfaceNumber
      436 => x"00",  -- bAlternateSetting
      437 => x"00",  -- bNumEndpoints
      438 => x"01",  -- bInterfaceClass
      439 => x"01",  -- bInterfaceSubClass
      440 => x"20",  -- bInterfaceProtocol
      441 => x"00",  -- iInterface
      -- Usb2UAC2FuncHeaderDesc
      442 => x"09",  -- bLength
      443 => x"24",  -- bDescriptorType
      444 => x"01",  -- bDescriptorSubtype
      445 => x"00",  -- bcdADC
      446 => x"02",
      447 => x"03",  -- bCategory
      448 => x"3c",  -- wTotalLength
      449 => x"00",
      450 => x"00",  -- bmControls
      -- Usb2UAC2ClockSourceDesc
      451 => x"08",  -- bLength
      452 => x"24",  -- bDescriptorType
      453 => x"0a",  -- bDescriptorSubtype
      454 => x"09",  -- bClockID
      455 => x"00",  -- bmAttributes
      456 => x"01",  -- bmControls
      457 => x"00",  -- bAssocTerminal
      458 => x"00",  -- iClockSource
      -- Usb2UAC2InputTerminalDesc
      459 => x"11",  -- bLength
      460 => x"24",  -- bDescriptorType
      461 => x"02",  -- bDescriptorSubtype
      462 => x"01",  -- bTerminalID
      463 => x"01",  -- wTerminalType
      464 => x"02",
      465 => x"00",  -- bAssocTerminal
      466 => x"09",  -- bCSourceID
      467 => x"01",  -- bNrChannels
      468 => x"04",  -- bmChannelConfig
      469 => x"00",
      470 => x"00",
      471 => x"00",
      472 => x"00",  -- iChannelNames
      473 => x"00",  -- bmControls
      474 => x"00",
      475 => x"00",  -- iTerminal
      -- Usb2UAC2MonoFeatureUnitDesc
      476 => x"0e",  -- bLength
      477 => x"24",  -- bDescriptorType
      478 => x"06",  -- bDescriptorSubtype
      479 => x"02",  -- bUnitID
      480 => x"01",  -- bSourceID
      481 => x"0f",  -- bmaControls0
      482 => x"00",
      483 => x"00",
      484 => x"00",
      485 => x"0f",  -- bmaControls1
      486 => x"00",
      487 => x"00",
      488 => x"00",
      489 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      490 => x"0c",  -- bLength
      491 => x"24",  -- bDescriptorType
      492 => x"03",  -- bDescriptorSubtype
      493 => x"03",  -- bTerminalID
      494 => x"01",  -- wTerminalType
      495 => x"01",
      496 => x"00",  -- bAssocTerminal
      497 => x"02",  -- bSourceID
      498 => x"09",  -- bCSourceID
      499 => x"00",  -- bmControls
      500 => x"00",
      501 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      502 => x"09",  -- bLength
      503 => x"04",  -- bDescriptorType
      504 => x"03",  -- bInterfaceNumber
      505 => x"00",  -- bAlternateSetting
      506 => x"00",  -- bNumEndpoints
      507 => x"01",  -- bInterfaceClass
      508 => x"02",  -- bInterfaceSubClass
      509 => x"20",  -- bInterfaceProtocol
      510 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      511 => x"09",  -- bLength
      512 => x"04",  -- bDescriptorType
      513 => x"03",  -- bInterfaceNumber
      514 => x"01",  -- bAlternateSetting
      515 => x"01",  -- bNumEndpoints
      516 => x"01",  -- bInterfaceClass
      517 => x"02",  -- bInterfaceSubClass
      518 => x"20",  -- bInterfaceProtocol
      519 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      520 => x"10",  -- bLength
      521 => x"24",  -- bDescriptorType
      522 => x"01",  -- bDescriptorSubtype
      523 => x"03",  -- bTerminalLink
      524 => x"00",  -- bmControls
      525 => x"01",  -- bFormatType
      526 => x"01",  -- bmFormats
      527 => x"00",
      528 => x"00",
      529 => x"00",
      530 => x"01",  -- bNrChannels
      531 => x"04",  -- bmChannelConfig
      532 => x"00",
      533 => x"00",
      534 => x"00",
      535 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      536 => x"06",  -- bLength
      537 => x"24",  -- bDescriptorType
      538 => x"02",  -- bDescriptorSubtype
      539 => x"01",  -- bFormatType
      540 => x"02",  -- bSubslotSize
      541 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      542 => x"07",  -- bLength
      543 => x"05",  -- bDescriptorType
      544 => x"83",  -- bEndpointAddress
      545 => x"05",  -- bmAttributes
      546 => x"62",  -- wMaxPacketSize
      547 => x"00",
      548 => x"04",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      549 => x"08",  -- bLength
      550 => x"25",  -- bDescriptorType
      551 => x"01",  -- bDescriptorSubtype
      552 => x"00",  -- bmAttributes
      553 => x"00",  -- bmControls
      554 => x"00",  -- bLockDelayUnits
      555 => x"00",  -- wLockDelay
      556 => x"00",
      -- Usb2InterfaceAssociationDesc
      557 => x"08",  -- bLength
      558 => x"0b",  -- bDescriptorType
      559 => x"04",  -- bFirstInterface
      560 => x"02",  -- bInterfaceCount
      561 => x"02",  -- bFunctionClass
      562 => x"0d",  -- bFunctionSubClass
      563 => x"00",  -- bFunctionProtocol
      564 => x"04",  -- iFunction
      -- Usb2InterfaceDesc
      565 => x"09",  -- bLength
      566 => x"04",  -- bDescriptorType
      567 => x"04",  -- bInterfaceNumber
      568 => x"00",  -- bAlternateSetting
      569 => x"01",  -- bNumEndpoints
      570 => x"02",  -- bInterfaceClass
      571 => x"0d",  -- bInterfaceSubClass
      572 => x"00",  -- bInterfaceProtocol
      573 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      574 => x"05",  -- bLength
      575 => x"24",  -- bDescriptorType
      576 => x"00",  -- bDescriptorSubtype
      577 => x"20",  -- bcdCDC
      578 => x"01",
      -- Usb2CDCFuncUnionDesc
      579 => x"05",  -- bLength
      580 => x"24",  -- bDescriptorType
      581 => x"06",  -- bDescriptorSubtype
      582 => x"04",  -- bControlInterface
      583 => x"05",
      -- Usb2CDCFuncEthernetDesc
      584 => x"0d",  -- bLength
      585 => x"24",  -- bDescriptorType
      586 => x"0f",  -- bDescriptorSubtype
      587 => x"05",  -- iMACAddress
      588 => x"00",  -- bmEthernetStatistics
      589 => x"00",
      590 => x"00",
      591 => x"00",
      592 => x"ea",  -- wMaxSegmentSize
      593 => x"05",
      594 => x"20",  -- wNumberMCFilters
      595 => x"80",
      596 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      597 => x"06",  -- bLength
      598 => x"24",  -- bDescriptorType
      599 => x"1a",  -- bDescriptorSubtype
      600 => x"00",  -- bcdNcmVersion
      601 => x"01",
      602 => x"01",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      603 => x"07",  -- bLength
      604 => x"05",  -- bDescriptorType
      605 => x"85",  -- bEndpointAddress
      606 => x"03",  -- bmAttributes
      607 => x"10",  -- wMaxPacketSize
      608 => x"00",
      609 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      610 => x"09",  -- bLength
      611 => x"04",  -- bDescriptorType
      612 => x"05",  -- bInterfaceNumber
      613 => x"00",  -- bAlternateSetting
      614 => x"00",  -- bNumEndpoints
      615 => x"0a",  -- bInterfaceClass
      616 => x"00",  -- bInterfaceSubClass
      617 => x"01",  -- bInterfaceProtocol
      618 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      619 => x"09",  -- bLength
      620 => x"04",  -- bDescriptorType
      621 => x"05",  -- bInterfaceNumber
      622 => x"01",  -- bAlternateSetting
      623 => x"02",  -- bNumEndpoints
      624 => x"0a",  -- bInterfaceClass
      625 => x"00",  -- bInterfaceSubClass
      626 => x"01",  -- bInterfaceProtocol
      627 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      628 => x"07",  -- bLength
      629 => x"05",  -- bDescriptorType
      630 => x"84",  -- bEndpointAddress
      631 => x"02",  -- bmAttributes
      632 => x"00",  -- wMaxPacketSize
      633 => x"02",
      634 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      635 => x"07",  -- bLength
      636 => x"05",  -- bDescriptorType
      637 => x"04",  -- bEndpointAddress
      638 => x"02",  -- bmAttributes
      639 => x"00",  -- wMaxPacketSize
      640 => x"02",
      641 => x"00",  -- bInterval
      -- Usb2StringDesc
      642 => x"04",  -- bLength
      643 => x"03",  -- bDescriptorType
      644 => x"09",  -- langID 0x0409
      645 => x"04",
      -- Usb2StringDesc
      646 => x"46",  -- bLength
      647 => x"03",  -- bDescriptorType
      648 => x"54",  -- T
      649 => x"00",
      650 => x"69",  -- i
      651 => x"00",
      652 => x"6c",  -- l
      653 => x"00",
      654 => x"6c",  -- l
      655 => x"00",
      656 => x"27",  -- '
      657 => x"00",
      658 => x"73",  -- s
      659 => x"00",
      660 => x"20",  --  
      661 => x"00",
      662 => x"4d",  -- M
      663 => x"00",
      664 => x"65",  -- e
      665 => x"00",
      666 => x"63",  -- c
      667 => x"00",
      668 => x"61",  -- a
      669 => x"00",
      670 => x"74",  -- t
      671 => x"00",
      672 => x"69",  -- i
      673 => x"00",
      674 => x"63",  -- c
      675 => x"00",
      676 => x"61",  -- a
      677 => x"00",
      678 => x"20",  --  
      679 => x"00",
      680 => x"55",  -- U
      681 => x"00",
      682 => x"53",  -- S
      683 => x"00",
      684 => x"42",  -- B
      685 => x"00",
      686 => x"20",  --  
      687 => x"00",
      688 => x"45",  -- E
      689 => x"00",
      690 => x"78",  -- x
      691 => x"00",
      692 => x"61",  -- a
      693 => x"00",
      694 => x"6d",  -- m
      695 => x"00",
      696 => x"70",  -- p
      697 => x"00",
      698 => x"6c",  -- l
      699 => x"00",
      700 => x"65",  -- e
      701 => x"00",
      702 => x"20",  --  
      703 => x"00",
      704 => x"44",  -- D
      705 => x"00",
      706 => x"65",  -- e
      707 => x"00",
      708 => x"76",  -- v
      709 => x"00",
      710 => x"69",  -- i
      711 => x"00",
      712 => x"63",  -- c
      713 => x"00",
      714 => x"65",  -- e
      715 => x"00",
      -- Usb2StringDesc
      716 => x"1a",  -- bLength
      717 => x"03",  -- bDescriptorType
      718 => x"4d",  -- M
      719 => x"00",
      720 => x"65",  -- e
      721 => x"00",
      722 => x"63",  -- c
      723 => x"00",
      724 => x"61",  -- a
      725 => x"00",
      726 => x"74",  -- t
      727 => x"00",
      728 => x"69",  -- i
      729 => x"00",
      730 => x"63",  -- c
      731 => x"00",
      732 => x"61",  -- a
      733 => x"00",
      734 => x"20",  --  
      735 => x"00",
      736 => x"41",  -- A
      737 => x"00",
      738 => x"43",  -- C
      739 => x"00",
      740 => x"4d",  -- M
      741 => x"00",
      -- Usb2StringDesc
      742 => x"32",  -- bLength
      743 => x"03",  -- bDescriptorType
      744 => x"4d",  -- M
      745 => x"00",
      746 => x"65",  -- e
      747 => x"00",
      748 => x"63",  -- c
      749 => x"00",
      750 => x"61",  -- a
      751 => x"00",
      752 => x"74",  -- t
      753 => x"00",
      754 => x"69",  -- i
      755 => x"00",
      756 => x"63",  -- c
      757 => x"00",
      758 => x"61",  -- a
      759 => x"00",
      760 => x"20",  --  
      761 => x"00",
      762 => x"55",  -- U
      763 => x"00",
      764 => x"41",  -- A
      765 => x"00",
      766 => x"43",  -- C
      767 => x"00",
      768 => x"32",  -- 2
      769 => x"00",
      770 => x"20",  --  
      771 => x"00",
      772 => x"4d",  -- M
      773 => x"00",
      774 => x"69",  -- i
      775 => x"00",
      776 => x"63",  -- c
      777 => x"00",
      778 => x"72",  -- r
      779 => x"00",
      780 => x"6f",  -- o
      781 => x"00",
      782 => x"70",  -- p
      783 => x"00",
      784 => x"68",  -- h
      785 => x"00",
      786 => x"6f",  -- o
      787 => x"00",
      788 => x"6e",  -- n
      789 => x"00",
      790 => x"65",  -- e
      791 => x"00",
      -- Usb2StringDesc
      792 => x"1a",  -- bLength
      793 => x"03",  -- bDescriptorType
      794 => x"4d",  -- M
      795 => x"00",
      796 => x"65",  -- e
      797 => x"00",
      798 => x"63",  -- c
      799 => x"00",
      800 => x"61",  -- a
      801 => x"00",
      802 => x"74",  -- t
      803 => x"00",
      804 => x"69",  -- i
      805 => x"00",
      806 => x"63",  -- c
      807 => x"00",
      808 => x"61",  -- a
      809 => x"00",
      810 => x"20",  --  
      811 => x"00",
      812 => x"4e",  -- N
      813 => x"00",
      814 => x"43",  -- C
      815 => x"00",
      816 => x"4d",  -- M
      817 => x"00",
      -- Usb2StringDesc
      818 => x"1a",  -- bLength
      819 => x"03",  -- bDescriptorType
      820 => x"30",  -- 0
      821 => x"00",
      822 => x"32",  -- 2
      823 => x"00",
      824 => x"64",  -- d
      825 => x"00",
      826 => x"65",  -- e
      827 => x"00",
      828 => x"61",  -- a
      829 => x"00",
      830 => x"64",  -- d
      831 => x"00",
      832 => x"62",  -- b
      833 => x"00",
      834 => x"65",  -- e
      835 => x"00",
      836 => x"65",  -- e
      837 => x"00",
      838 => x"66",  -- f
      839 => x"00",
      840 => x"33",  -- 3
      841 => x"00",
      842 => x"31",  -- 1
      843 => x"00",
      -- Usb2SentinelDesc
      844 => x"02",  -- bLength
      845 => x"ff"   -- bDescriptorType
      );
   begin
      return c;
   end function usb2AppGetDescriptors;

   constant USB2_APP_DESCRIPTORS_C : Usb2ByteArray := usb2AppGetDescriptors;

end package body Usb2AppCfgPkg;
