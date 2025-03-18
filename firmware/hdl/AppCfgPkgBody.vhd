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
       30 => x"20",  -- wTotalLength
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
      126 => x"38",  -- wTotalLength
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
      154 => x"0a",  -- bLength
      155 => x"24",  -- bDescriptorType
      156 => x"06",  -- bDescriptorSubtype
      157 => x"02",  -- bUnitID
      158 => x"01",  -- bSourceID
      159 => x"0f",  -- bmaControls0
      160 => x"00",
      161 => x"00",
      162 => x"00",
      163 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      164 => x"0c",  -- bLength
      165 => x"24",  -- bDescriptorType
      166 => x"03",  -- bDescriptorSubtype
      167 => x"03",  -- bTerminalID
      168 => x"01",  -- wTerminalType
      169 => x"01",
      170 => x"00",  -- bAssocTerminal
      171 => x"02",  -- bSourceID
      172 => x"09",  -- bCSourceID
      173 => x"00",  -- bmControls
      174 => x"00",
      175 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      176 => x"09",  -- bLength
      177 => x"04",  -- bDescriptorType
      178 => x"03",  -- bInterfaceNumber
      179 => x"00",  -- bAlternateSetting
      180 => x"00",  -- bNumEndpoints
      181 => x"01",  -- bInterfaceClass
      182 => x"02",  -- bInterfaceSubClass
      183 => x"20",  -- bInterfaceProtocol
      184 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      185 => x"09",  -- bLength
      186 => x"04",  -- bDescriptorType
      187 => x"03",  -- bInterfaceNumber
      188 => x"01",  -- bAlternateSetting
      189 => x"01",  -- bNumEndpoints
      190 => x"01",  -- bInterfaceClass
      191 => x"02",  -- bInterfaceSubClass
      192 => x"20",  -- bInterfaceProtocol
      193 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      194 => x"10",  -- bLength
      195 => x"24",  -- bDescriptorType
      196 => x"01",  -- bDescriptorSubtype
      197 => x"03",  -- bTerminalLink
      198 => x"00",  -- bmControls
      199 => x"01",  -- bFormatType
      200 => x"01",  -- bmFormats
      201 => x"00",
      202 => x"00",
      203 => x"00",
      204 => x"01",  -- bNrChannels
      205 => x"04",  -- bmChannelConfig
      206 => x"00",
      207 => x"00",
      208 => x"00",
      209 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      210 => x"06",  -- bLength
      211 => x"24",  -- bDescriptorType
      212 => x"02",  -- bDescriptorSubtype
      213 => x"01",  -- bFormatType
      214 => x"02",  -- bSubslotSize
      215 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      216 => x"07",  -- bLength
      217 => x"05",  -- bDescriptorType
      218 => x"83",  -- bEndpointAddress
      219 => x"05",  -- bmAttributes
      220 => x"62",  -- wMaxPacketSize
      221 => x"00",
      222 => x"01",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      223 => x"08",  -- bLength
      224 => x"25",  -- bDescriptorType
      225 => x"01",  -- bDescriptorSubtype
      226 => x"00",  -- bmAttributes
      227 => x"00",  -- bmControls
      228 => x"00",  -- bLockDelayUnits
      229 => x"00",  -- wLockDelay
      230 => x"00",
      -- Usb2InterfaceAssociationDesc
      231 => x"08",  -- bLength
      232 => x"0b",  -- bDescriptorType
      233 => x"04",  -- bFirstInterface
      234 => x"02",  -- bInterfaceCount
      235 => x"02",  -- bFunctionClass
      236 => x"0d",  -- bFunctionSubClass
      237 => x"00",  -- bFunctionProtocol
      238 => x"04",  -- iFunction
      -- Usb2InterfaceDesc
      239 => x"09",  -- bLength
      240 => x"04",  -- bDescriptorType
      241 => x"04",  -- bInterfaceNumber
      242 => x"00",  -- bAlternateSetting
      243 => x"01",  -- bNumEndpoints
      244 => x"02",  -- bInterfaceClass
      245 => x"0d",  -- bInterfaceSubClass
      246 => x"00",  -- bInterfaceProtocol
      247 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      248 => x"05",  -- bLength
      249 => x"24",  -- bDescriptorType
      250 => x"00",  -- bDescriptorSubtype
      251 => x"20",  -- bcdCDC
      252 => x"01",
      -- Usb2CDCFuncUnionDesc
      253 => x"05",  -- bLength
      254 => x"24",  -- bDescriptorType
      255 => x"06",  -- bDescriptorSubtype
      256 => x"04",  -- bControlInterface
      257 => x"05",
      -- Usb2CDCFuncEthernetDesc
      258 => x"0d",  -- bLength
      259 => x"24",  -- bDescriptorType
      260 => x"0f",  -- bDescriptorSubtype
      261 => x"05",  -- iMACAddress
      262 => x"00",  -- bmEthernetStatistics
      263 => x"00",
      264 => x"00",
      265 => x"00",
      266 => x"ea",  -- wMaxSegmentSize
      267 => x"05",
      268 => x"20",  -- wNumberMCFilters
      269 => x"80",
      270 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      271 => x"06",  -- bLength
      272 => x"24",  -- bDescriptorType
      273 => x"1a",  -- bDescriptorSubtype
      274 => x"00",  -- bcdNcmVersion
      275 => x"01",
      276 => x"01",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      277 => x"07",  -- bLength
      278 => x"05",  -- bDescriptorType
      279 => x"85",  -- bEndpointAddress
      280 => x"03",  -- bmAttributes
      281 => x"10",  -- wMaxPacketSize
      282 => x"00",
      283 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
      284 => x"09",  -- bLength
      285 => x"04",  -- bDescriptorType
      286 => x"05",  -- bInterfaceNumber
      287 => x"00",  -- bAlternateSetting
      288 => x"00",  -- bNumEndpoints
      289 => x"0a",  -- bInterfaceClass
      290 => x"00",  -- bInterfaceSubClass
      291 => x"01",  -- bInterfaceProtocol
      292 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      293 => x"09",  -- bLength
      294 => x"04",  -- bDescriptorType
      295 => x"05",  -- bInterfaceNumber
      296 => x"01",  -- bAlternateSetting
      297 => x"02",  -- bNumEndpoints
      298 => x"0a",  -- bInterfaceClass
      299 => x"00",  -- bInterfaceSubClass
      300 => x"01",  -- bInterfaceProtocol
      301 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      302 => x"07",  -- bLength
      303 => x"05",  -- bDescriptorType
      304 => x"84",  -- bEndpointAddress
      305 => x"02",  -- bmAttributes
      306 => x"40",  -- wMaxPacketSize
      307 => x"00",
      308 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      309 => x"07",  -- bLength
      310 => x"05",  -- bDescriptorType
      311 => x"04",  -- bEndpointAddress
      312 => x"02",  -- bmAttributes
      313 => x"40",  -- wMaxPacketSize
      314 => x"00",
      315 => x"00",  -- bInterval
      -- Usb2SentinelDesc
      316 => x"02",  -- bLength
      317 => x"ff",  -- bDescriptorType
      -- Usb2DeviceDesc
      318 => x"12",  -- bLength
      319 => x"01",  -- bDescriptorType
      320 => x"00",  -- bcdUSB
      321 => x"02",
      322 => x"ef",  -- bDeviceClass
      323 => x"02",  -- bDeviceSubClass
      324 => x"01",  -- bDeviceProtocol
      325 => x"40",  -- bMaxPacketSize0
      326 => x"09",  -- idVendor
      327 => x"12",
      328 => x"01",  -- idProduct
      329 => x"00",
      330 => x"00",  -- bcdDevice
      331 => x"01",
      332 => x"00",  -- iManufacturer
      333 => x"01",  -- iProduct
      334 => x"00",  -- iSerialNumber
      335 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
      336 => x"0a",  -- bLength
      337 => x"06",  -- bDescriptorType
      338 => x"00",  -- bcdUSB
      339 => x"02",
      340 => x"ef",  -- bDeviceClass
      341 => x"02",  -- bDeviceSubClass
      342 => x"01",  -- bDeviceProtocol
      343 => x"40",  -- bMaxPacketSize0
      344 => x"01",  -- bNumConfigurations
      345 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
      346 => x"09",  -- bLength
      347 => x"02",  -- bDescriptorType
      348 => x"20",  -- wTotalLength
      349 => x"01",
      350 => x"06",  -- bNumInterfaces
      351 => x"01",  -- bConfigurationValue
      352 => x"00",  -- iConfiguration
      353 => x"a0",  -- bmAttributes
      354 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
      355 => x"08",  -- bLength
      356 => x"0b",  -- bDescriptorType
      357 => x"00",  -- bFirstInterface
      358 => x"02",  -- bInterfaceCount
      359 => x"02",  -- bFunctionClass
      360 => x"02",  -- bFunctionSubClass
      361 => x"00",  -- bFunctionProtocol
      362 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
      363 => x"09",  -- bLength
      364 => x"04",  -- bDescriptorType
      365 => x"00",  -- bInterfaceNumber
      366 => x"00",  -- bAlternateSetting
      367 => x"01",  -- bNumEndpoints
      368 => x"02",  -- bInterfaceClass
      369 => x"02",  -- bInterfaceSubClass
      370 => x"00",  -- bInterfaceProtocol
      371 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      372 => x"05",  -- bLength
      373 => x"24",  -- bDescriptorType
      374 => x"00",  -- bDescriptorSubtype
      375 => x"20",  -- bcdCDC
      376 => x"01",
      -- Usb2CDCFuncCallManagementDesc
      377 => x"05",  -- bLength
      378 => x"24",  -- bDescriptorType
      379 => x"01",  -- bDescriptorSubtype
      380 => x"00",  -- bmCapabilities
      381 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
      382 => x"04",  -- bLength
      383 => x"24",  -- bDescriptorType
      384 => x"02",  -- bDescriptorSubtype
      385 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
      386 => x"05",  -- bLength
      387 => x"24",  -- bDescriptorType
      388 => x"06",  -- bDescriptorSubtype
      389 => x"00",  -- bControlInterface
      390 => x"01",
      -- Usb2EndpointDesc
      391 => x"07",  -- bLength
      392 => x"05",  -- bDescriptorType
      393 => x"82",  -- bEndpointAddress
      394 => x"03",  -- bmAttributes
      395 => x"08",  -- wMaxPacketSize
      396 => x"00",
      397 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      398 => x"09",  -- bLength
      399 => x"04",  -- bDescriptorType
      400 => x"01",  -- bInterfaceNumber
      401 => x"00",  -- bAlternateSetting
      402 => x"02",  -- bNumEndpoints
      403 => x"0a",  -- bInterfaceClass
      404 => x"00",  -- bInterfaceSubClass
      405 => x"00",  -- bInterfaceProtocol
      406 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      407 => x"07",  -- bLength
      408 => x"05",  -- bDescriptorType
      409 => x"81",  -- bEndpointAddress
      410 => x"02",  -- bmAttributes
      411 => x"00",  -- wMaxPacketSize
      412 => x"02",
      413 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      414 => x"07",  -- bLength
      415 => x"05",  -- bDescriptorType
      416 => x"01",  -- bEndpointAddress
      417 => x"02",  -- bmAttributes
      418 => x"00",  -- wMaxPacketSize
      419 => x"02",
      420 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      421 => x"08",  -- bLength
      422 => x"0b",  -- bDescriptorType
      423 => x"02",  -- bFirstInterface
      424 => x"02",  -- bInterfaceCount
      425 => x"01",  -- bFunctionClass
      426 => x"00",  -- bFunctionSubClass
      427 => x"20",  -- bFunctionProtocol
      428 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      429 => x"09",  -- bLength
      430 => x"04",  -- bDescriptorType
      431 => x"02",  -- bInterfaceNumber
      432 => x"00",  -- bAlternateSetting
      433 => x"00",  -- bNumEndpoints
      434 => x"01",  -- bInterfaceClass
      435 => x"01",  -- bInterfaceSubClass
      436 => x"20",  -- bInterfaceProtocol
      437 => x"00",  -- iInterface
      -- Usb2UAC2FuncHeaderDesc
      438 => x"09",  -- bLength
      439 => x"24",  -- bDescriptorType
      440 => x"01",  -- bDescriptorSubtype
      441 => x"00",  -- bcdADC
      442 => x"02",
      443 => x"03",  -- bCategory
      444 => x"38",  -- wTotalLength
      445 => x"00",
      446 => x"00",  -- bmControls
      -- Usb2UAC2ClockSourceDesc
      447 => x"08",  -- bLength
      448 => x"24",  -- bDescriptorType
      449 => x"0a",  -- bDescriptorSubtype
      450 => x"09",  -- bClockID
      451 => x"00",  -- bmAttributes
      452 => x"01",  -- bmControls
      453 => x"00",  -- bAssocTerminal
      454 => x"00",  -- iClockSource
      -- Usb2UAC2InputTerminalDesc
      455 => x"11",  -- bLength
      456 => x"24",  -- bDescriptorType
      457 => x"02",  -- bDescriptorSubtype
      458 => x"01",  -- bTerminalID
      459 => x"01",  -- wTerminalType
      460 => x"02",
      461 => x"00",  -- bAssocTerminal
      462 => x"09",  -- bCSourceID
      463 => x"01",  -- bNrChannels
      464 => x"04",  -- bmChannelConfig
      465 => x"00",
      466 => x"00",
      467 => x"00",
      468 => x"00",  -- iChannelNames
      469 => x"00",  -- bmControls
      470 => x"00",
      471 => x"00",  -- iTerminal
      -- Usb2UAC2MonoFeatureUnitDesc
      472 => x"0a",  -- bLength
      473 => x"24",  -- bDescriptorType
      474 => x"06",  -- bDescriptorSubtype
      475 => x"02",  -- bUnitID
      476 => x"01",  -- bSourceID
      477 => x"0f",  -- bmaControls0
      478 => x"00",
      479 => x"00",
      480 => x"00",
      481 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      482 => x"0c",  -- bLength
      483 => x"24",  -- bDescriptorType
      484 => x"03",  -- bDescriptorSubtype
      485 => x"03",  -- bTerminalID
      486 => x"01",  -- wTerminalType
      487 => x"01",
      488 => x"00",  -- bAssocTerminal
      489 => x"02",  -- bSourceID
      490 => x"09",  -- bCSourceID
      491 => x"00",  -- bmControls
      492 => x"00",
      493 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      494 => x"09",  -- bLength
      495 => x"04",  -- bDescriptorType
      496 => x"03",  -- bInterfaceNumber
      497 => x"00",  -- bAlternateSetting
      498 => x"00",  -- bNumEndpoints
      499 => x"01",  -- bInterfaceClass
      500 => x"02",  -- bInterfaceSubClass
      501 => x"20",  -- bInterfaceProtocol
      502 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      503 => x"09",  -- bLength
      504 => x"04",  -- bDescriptorType
      505 => x"03",  -- bInterfaceNumber
      506 => x"01",  -- bAlternateSetting
      507 => x"01",  -- bNumEndpoints
      508 => x"01",  -- bInterfaceClass
      509 => x"02",  -- bInterfaceSubClass
      510 => x"20",  -- bInterfaceProtocol
      511 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      512 => x"10",  -- bLength
      513 => x"24",  -- bDescriptorType
      514 => x"01",  -- bDescriptorSubtype
      515 => x"03",  -- bTerminalLink
      516 => x"00",  -- bmControls
      517 => x"01",  -- bFormatType
      518 => x"01",  -- bmFormats
      519 => x"00",
      520 => x"00",
      521 => x"00",
      522 => x"01",  -- bNrChannels
      523 => x"04",  -- bmChannelConfig
      524 => x"00",
      525 => x"00",
      526 => x"00",
      527 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      528 => x"06",  -- bLength
      529 => x"24",  -- bDescriptorType
      530 => x"02",  -- bDescriptorSubtype
      531 => x"01",  -- bFormatType
      532 => x"02",  -- bSubslotSize
      533 => x"10",  -- bBitResolution
      -- Usb2EndpointDesc
      534 => x"07",  -- bLength
      535 => x"05",  -- bDescriptorType
      536 => x"83",  -- bEndpointAddress
      537 => x"05",  -- bmAttributes
      538 => x"62",  -- wMaxPacketSize
      539 => x"00",
      540 => x"04",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      541 => x"08",  -- bLength
      542 => x"25",  -- bDescriptorType
      543 => x"01",  -- bDescriptorSubtype
      544 => x"00",  -- bmAttributes
      545 => x"00",  -- bmControls
      546 => x"00",  -- bLockDelayUnits
      547 => x"00",  -- wLockDelay
      548 => x"00",
      -- Usb2InterfaceAssociationDesc
      549 => x"08",  -- bLength
      550 => x"0b",  -- bDescriptorType
      551 => x"04",  -- bFirstInterface
      552 => x"02",  -- bInterfaceCount
      553 => x"02",  -- bFunctionClass
      554 => x"0d",  -- bFunctionSubClass
      555 => x"00",  -- bFunctionProtocol
      556 => x"04",  -- iFunction
      -- Usb2InterfaceDesc
      557 => x"09",  -- bLength
      558 => x"04",  -- bDescriptorType
      559 => x"04",  -- bInterfaceNumber
      560 => x"00",  -- bAlternateSetting
      561 => x"01",  -- bNumEndpoints
      562 => x"02",  -- bInterfaceClass
      563 => x"0d",  -- bInterfaceSubClass
      564 => x"00",  -- bInterfaceProtocol
      565 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      566 => x"05",  -- bLength
      567 => x"24",  -- bDescriptorType
      568 => x"00",  -- bDescriptorSubtype
      569 => x"20",  -- bcdCDC
      570 => x"01",
      -- Usb2CDCFuncUnionDesc
      571 => x"05",  -- bLength
      572 => x"24",  -- bDescriptorType
      573 => x"06",  -- bDescriptorSubtype
      574 => x"04",  -- bControlInterface
      575 => x"05",
      -- Usb2CDCFuncEthernetDesc
      576 => x"0d",  -- bLength
      577 => x"24",  -- bDescriptorType
      578 => x"0f",  -- bDescriptorSubtype
      579 => x"05",  -- iMACAddress
      580 => x"00",  -- bmEthernetStatistics
      581 => x"00",
      582 => x"00",
      583 => x"00",
      584 => x"ea",  -- wMaxSegmentSize
      585 => x"05",
      586 => x"20",  -- wNumberMCFilters
      587 => x"80",
      588 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      589 => x"06",  -- bLength
      590 => x"24",  -- bDescriptorType
      591 => x"1a",  -- bDescriptorSubtype
      592 => x"00",  -- bcdNcmVersion
      593 => x"01",
      594 => x"01",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      595 => x"07",  -- bLength
      596 => x"05",  -- bDescriptorType
      597 => x"85",  -- bEndpointAddress
      598 => x"03",  -- bmAttributes
      599 => x"10",  -- wMaxPacketSize
      600 => x"00",
      601 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      602 => x"09",  -- bLength
      603 => x"04",  -- bDescriptorType
      604 => x"05",  -- bInterfaceNumber
      605 => x"00",  -- bAlternateSetting
      606 => x"00",  -- bNumEndpoints
      607 => x"0a",  -- bInterfaceClass
      608 => x"00",  -- bInterfaceSubClass
      609 => x"01",  -- bInterfaceProtocol
      610 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      611 => x"09",  -- bLength
      612 => x"04",  -- bDescriptorType
      613 => x"05",  -- bInterfaceNumber
      614 => x"01",  -- bAlternateSetting
      615 => x"02",  -- bNumEndpoints
      616 => x"0a",  -- bInterfaceClass
      617 => x"00",  -- bInterfaceSubClass
      618 => x"01",  -- bInterfaceProtocol
      619 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      620 => x"07",  -- bLength
      621 => x"05",  -- bDescriptorType
      622 => x"84",  -- bEndpointAddress
      623 => x"02",  -- bmAttributes
      624 => x"00",  -- wMaxPacketSize
      625 => x"02",
      626 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      627 => x"07",  -- bLength
      628 => x"05",  -- bDescriptorType
      629 => x"04",  -- bEndpointAddress
      630 => x"02",  -- bmAttributes
      631 => x"00",  -- wMaxPacketSize
      632 => x"02",
      633 => x"00",  -- bInterval
      -- Usb2StringDesc
      634 => x"04",  -- bLength
      635 => x"03",  -- bDescriptorType
      636 => x"09",  -- langID 0x0409
      637 => x"04",
      -- Usb2StringDesc
      638 => x"46",  -- bLength
      639 => x"03",  -- bDescriptorType
      640 => x"54",  -- T
      641 => x"00",
      642 => x"69",  -- i
      643 => x"00",
      644 => x"6c",  -- l
      645 => x"00",
      646 => x"6c",  -- l
      647 => x"00",
      648 => x"27",  -- '
      649 => x"00",
      650 => x"73",  -- s
      651 => x"00",
      652 => x"20",  --  
      653 => x"00",
      654 => x"4d",  -- M
      655 => x"00",
      656 => x"65",  -- e
      657 => x"00",
      658 => x"63",  -- c
      659 => x"00",
      660 => x"61",  -- a
      661 => x"00",
      662 => x"74",  -- t
      663 => x"00",
      664 => x"69",  -- i
      665 => x"00",
      666 => x"63",  -- c
      667 => x"00",
      668 => x"61",  -- a
      669 => x"00",
      670 => x"20",  --  
      671 => x"00",
      672 => x"55",  -- U
      673 => x"00",
      674 => x"53",  -- S
      675 => x"00",
      676 => x"42",  -- B
      677 => x"00",
      678 => x"20",  --  
      679 => x"00",
      680 => x"45",  -- E
      681 => x"00",
      682 => x"78",  -- x
      683 => x"00",
      684 => x"61",  -- a
      685 => x"00",
      686 => x"6d",  -- m
      687 => x"00",
      688 => x"70",  -- p
      689 => x"00",
      690 => x"6c",  -- l
      691 => x"00",
      692 => x"65",  -- e
      693 => x"00",
      694 => x"20",  --  
      695 => x"00",
      696 => x"44",  -- D
      697 => x"00",
      698 => x"65",  -- e
      699 => x"00",
      700 => x"76",  -- v
      701 => x"00",
      702 => x"69",  -- i
      703 => x"00",
      704 => x"63",  -- c
      705 => x"00",
      706 => x"65",  -- e
      707 => x"00",
      -- Usb2StringDesc
      708 => x"1a",  -- bLength
      709 => x"03",  -- bDescriptorType
      710 => x"4d",  -- M
      711 => x"00",
      712 => x"65",  -- e
      713 => x"00",
      714 => x"63",  -- c
      715 => x"00",
      716 => x"61",  -- a
      717 => x"00",
      718 => x"74",  -- t
      719 => x"00",
      720 => x"69",  -- i
      721 => x"00",
      722 => x"63",  -- c
      723 => x"00",
      724 => x"61",  -- a
      725 => x"00",
      726 => x"20",  --  
      727 => x"00",
      728 => x"41",  -- A
      729 => x"00",
      730 => x"43",  -- C
      731 => x"00",
      732 => x"4d",  -- M
      733 => x"00",
      -- Usb2StringDesc
      734 => x"32",  -- bLength
      735 => x"03",  -- bDescriptorType
      736 => x"4d",  -- M
      737 => x"00",
      738 => x"65",  -- e
      739 => x"00",
      740 => x"63",  -- c
      741 => x"00",
      742 => x"61",  -- a
      743 => x"00",
      744 => x"74",  -- t
      745 => x"00",
      746 => x"69",  -- i
      747 => x"00",
      748 => x"63",  -- c
      749 => x"00",
      750 => x"61",  -- a
      751 => x"00",
      752 => x"20",  --  
      753 => x"00",
      754 => x"55",  -- U
      755 => x"00",
      756 => x"41",  -- A
      757 => x"00",
      758 => x"43",  -- C
      759 => x"00",
      760 => x"32",  -- 2
      761 => x"00",
      762 => x"20",  --  
      763 => x"00",
      764 => x"4d",  -- M
      765 => x"00",
      766 => x"69",  -- i
      767 => x"00",
      768 => x"63",  -- c
      769 => x"00",
      770 => x"72",  -- r
      771 => x"00",
      772 => x"6f",  -- o
      773 => x"00",
      774 => x"70",  -- p
      775 => x"00",
      776 => x"68",  -- h
      777 => x"00",
      778 => x"6f",  -- o
      779 => x"00",
      780 => x"6e",  -- n
      781 => x"00",
      782 => x"65",  -- e
      783 => x"00",
      -- Usb2StringDesc
      784 => x"1a",  -- bLength
      785 => x"03",  -- bDescriptorType
      786 => x"4d",  -- M
      787 => x"00",
      788 => x"65",  -- e
      789 => x"00",
      790 => x"63",  -- c
      791 => x"00",
      792 => x"61",  -- a
      793 => x"00",
      794 => x"74",  -- t
      795 => x"00",
      796 => x"69",  -- i
      797 => x"00",
      798 => x"63",  -- c
      799 => x"00",
      800 => x"61",  -- a
      801 => x"00",
      802 => x"20",  --  
      803 => x"00",
      804 => x"4e",  -- N
      805 => x"00",
      806 => x"43",  -- C
      807 => x"00",
      808 => x"4d",  -- M
      809 => x"00",
      -- Usb2StringDesc
      810 => x"1a",  -- bLength
      811 => x"03",  -- bDescriptorType
      812 => x"30",  -- 0
      813 => x"00",
      814 => x"32",  -- 2
      815 => x"00",
      816 => x"64",  -- d
      817 => x"00",
      818 => x"65",  -- e
      819 => x"00",
      820 => x"61",  -- a
      821 => x"00",
      822 => x"64",  -- d
      823 => x"00",
      824 => x"62",  -- b
      825 => x"00",
      826 => x"65",  -- e
      827 => x"00",
      828 => x"65",  -- e
      829 => x"00",
      830 => x"66",  -- f
      831 => x"00",
      832 => x"33",  -- 3
      833 => x"00",
      834 => x"31",  -- 1
      835 => x"00",
      -- Usb2SentinelDesc
      836 => x"02",  -- bLength
      837 => x"ff"   -- bDescriptorType
      );
   begin
      return c;
   end function usb2AppGetDescriptors;

   constant USB2_APP_DESCRIPTORS_C : Usb2ByteArray := usb2AppGetDescriptors;

end package body Usb2AppCfgPkg;
