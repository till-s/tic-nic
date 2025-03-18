-- Copyright Till Straumann, 2023. Licensed under the EUPL-1.2 or later.
-- You may obtain a copy of the license at
--   https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
-- This notice must not be removed.

-- THIS FILE WAS AUTOMATICALLY GENERATED; DO NOT EDIT!

-- Generated with: genAppCfgPkgBody.py -p 0x0001 -N 02deadbeef31 -a -f AppCfgPkgBody.vhd -m 0x8020

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

use     work.Usb2Pkg.all;
use     work.Usb2UtilPkg.all;
use     work.Usb2DescPkg.all;

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
       30 => x"28",  -- wTotalLength
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
      126 => x"40",  -- wTotalLength
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
      145 => x"02",  -- bNrChannels
      146 => x"03",  -- bmChannelConfig
      147 => x"00",
      148 => x"00",
      149 => x"00",
      150 => x"00",  -- iChannelNames
      151 => x"00",  -- bmControls
      152 => x"00",
      153 => x"00",  -- iTerminal
      -- Usb2UAC2StereoFeatureUnitDesc
      154 => x"12",  -- bLength
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
      167 => x"0f",  -- bmaControls2
      168 => x"00",
      169 => x"00",
      170 => x"00",
      171 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      172 => x"0c",  -- bLength
      173 => x"24",  -- bDescriptorType
      174 => x"03",  -- bDescriptorSubtype
      175 => x"03",  -- bTerminalID
      176 => x"01",  -- wTerminalType
      177 => x"01",
      178 => x"00",  -- bAssocTerminal
      179 => x"02",  -- bSourceID
      180 => x"09",  -- bCSourceID
      181 => x"00",  -- bmControls
      182 => x"00",
      183 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      184 => x"09",  -- bLength
      185 => x"04",  -- bDescriptorType
      186 => x"03",  -- bInterfaceNumber
      187 => x"00",  -- bAlternateSetting
      188 => x"00",  -- bNumEndpoints
      189 => x"01",  -- bInterfaceClass
      190 => x"02",  -- bInterfaceSubClass
      191 => x"20",  -- bInterfaceProtocol
      192 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      193 => x"09",  -- bLength
      194 => x"04",  -- bDescriptorType
      195 => x"03",  -- bInterfaceNumber
      196 => x"01",  -- bAlternateSetting
      197 => x"01",  -- bNumEndpoints
      198 => x"01",  -- bInterfaceClass
      199 => x"02",  -- bInterfaceSubClass
      200 => x"20",  -- bInterfaceProtocol
      201 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      202 => x"10",  -- bLength
      203 => x"24",  -- bDescriptorType
      204 => x"01",  -- bDescriptorSubtype
      205 => x"03",  -- bTerminalLink
      206 => x"00",  -- bmControls
      207 => x"01",  -- bFormatType
      208 => x"01",  -- bmFormats
      209 => x"00",
      210 => x"00",
      211 => x"00",
      212 => x"02",  -- bNrChannels
      213 => x"03",  -- bmChannelConfig
      214 => x"00",
      215 => x"00",
      216 => x"00",
      217 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      218 => x"06",  -- bLength
      219 => x"24",  -- bDescriptorType
      220 => x"02",  -- bDescriptorSubtype
      221 => x"01",  -- bFormatType
      222 => x"03",  -- bSubslotSize
      223 => x"18",  -- bBitResolution
      -- Usb2EndpointDesc
      224 => x"07",  -- bLength
      225 => x"05",  -- bDescriptorType
      226 => x"83",  -- bEndpointAddress
      227 => x"05",  -- bmAttributes
      228 => x"26",  -- wMaxPacketSize
      229 => x"01",
      230 => x"01",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      231 => x"08",  -- bLength
      232 => x"25",  -- bDescriptorType
      233 => x"01",  -- bDescriptorSubtype
      234 => x"00",  -- bmAttributes
      235 => x"00",  -- bmControls
      236 => x"00",  -- bLockDelayUnits
      237 => x"00",  -- wLockDelay
      238 => x"00",
      -- Usb2InterfaceAssociationDesc
      239 => x"08",  -- bLength
      240 => x"0b",  -- bDescriptorType
      241 => x"04",  -- bFirstInterface
      242 => x"02",  -- bInterfaceCount
      243 => x"02",  -- bFunctionClass
      244 => x"0d",  -- bFunctionSubClass
      245 => x"00",  -- bFunctionProtocol
      246 => x"04",  -- iFunction
      -- Usb2InterfaceDesc
      247 => x"09",  -- bLength
      248 => x"04",  -- bDescriptorType
      249 => x"04",  -- bInterfaceNumber
      250 => x"00",  -- bAlternateSetting
      251 => x"01",  -- bNumEndpoints
      252 => x"02",  -- bInterfaceClass
      253 => x"0d",  -- bInterfaceSubClass
      254 => x"00",  -- bInterfaceProtocol
      255 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      256 => x"05",  -- bLength
      257 => x"24",  -- bDescriptorType
      258 => x"00",  -- bDescriptorSubtype
      259 => x"20",  -- bcdCDC
      260 => x"01",
      -- Usb2CDCFuncUnionDesc
      261 => x"05",  -- bLength
      262 => x"24",  -- bDescriptorType
      263 => x"06",  -- bDescriptorSubtype
      264 => x"04",  -- bControlInterface
      265 => x"05",
      -- Usb2CDCFuncEthernetDesc
      266 => x"0d",  -- bLength
      267 => x"24",  -- bDescriptorType
      268 => x"0f",  -- bDescriptorSubtype
      269 => x"05",  -- iMACAddress
      270 => x"00",  -- bmEthernetStatistics
      271 => x"00",
      272 => x"00",
      273 => x"00",
      274 => x"ea",  -- wMaxSegmentSize
      275 => x"05",
      276 => x"20",  -- wNumberMCFilters
      277 => x"80",
      278 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      279 => x"06",  -- bLength
      280 => x"24",  -- bDescriptorType
      281 => x"1a",  -- bDescriptorSubtype
      282 => x"00",  -- bcdNcmVersion
      283 => x"01",
      284 => x"03",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      285 => x"07",  -- bLength
      286 => x"05",  -- bDescriptorType
      287 => x"85",  -- bEndpointAddress
      288 => x"03",  -- bmAttributes
      289 => x"10",  -- wMaxPacketSize
      290 => x"00",
      291 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
      292 => x"09",  -- bLength
      293 => x"04",  -- bDescriptorType
      294 => x"05",  -- bInterfaceNumber
      295 => x"00",  -- bAlternateSetting
      296 => x"00",  -- bNumEndpoints
      297 => x"0a",  -- bInterfaceClass
      298 => x"00",  -- bInterfaceSubClass
      299 => x"01",  -- bInterfaceProtocol
      300 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      301 => x"09",  -- bLength
      302 => x"04",  -- bDescriptorType
      303 => x"05",  -- bInterfaceNumber
      304 => x"01",  -- bAlternateSetting
      305 => x"02",  -- bNumEndpoints
      306 => x"0a",  -- bInterfaceClass
      307 => x"00",  -- bInterfaceSubClass
      308 => x"01",  -- bInterfaceProtocol
      309 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      310 => x"07",  -- bLength
      311 => x"05",  -- bDescriptorType
      312 => x"84",  -- bEndpointAddress
      313 => x"02",  -- bmAttributes
      314 => x"40",  -- wMaxPacketSize
      315 => x"00",
      316 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      317 => x"07",  -- bLength
      318 => x"05",  -- bDescriptorType
      319 => x"04",  -- bEndpointAddress
      320 => x"02",  -- bmAttributes
      321 => x"40",  -- wMaxPacketSize
      322 => x"00",
      323 => x"00",  -- bInterval
      -- Usb2SentinelDesc
      324 => x"02",  -- bLength
      325 => x"ff",  -- bDescriptorType
      -- Usb2DeviceDesc
      326 => x"12",  -- bLength
      327 => x"01",  -- bDescriptorType
      328 => x"00",  -- bcdUSB
      329 => x"02",
      330 => x"ef",  -- bDeviceClass
      331 => x"02",  -- bDeviceSubClass
      332 => x"01",  -- bDeviceProtocol
      333 => x"40",  -- bMaxPacketSize0
      334 => x"09",  -- idVendor
      335 => x"12",
      336 => x"01",  -- idProduct
      337 => x"00",
      338 => x"00",  -- bcdDevice
      339 => x"01",
      340 => x"00",  -- iManufacturer
      341 => x"01",  -- iProduct
      342 => x"00",  -- iSerialNumber
      343 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
      344 => x"0a",  -- bLength
      345 => x"06",  -- bDescriptorType
      346 => x"00",  -- bcdUSB
      347 => x"02",
      348 => x"ef",  -- bDeviceClass
      349 => x"02",  -- bDeviceSubClass
      350 => x"01",  -- bDeviceProtocol
      351 => x"40",  -- bMaxPacketSize0
      352 => x"01",  -- bNumConfigurations
      353 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
      354 => x"09",  -- bLength
      355 => x"02",  -- bDescriptorType
      356 => x"28",  -- wTotalLength
      357 => x"01",
      358 => x"06",  -- bNumInterfaces
      359 => x"01",  -- bConfigurationValue
      360 => x"00",  -- iConfiguration
      361 => x"a0",  -- bmAttributes
      362 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
      363 => x"08",  -- bLength
      364 => x"0b",  -- bDescriptorType
      365 => x"00",  -- bFirstInterface
      366 => x"02",  -- bInterfaceCount
      367 => x"02",  -- bFunctionClass
      368 => x"02",  -- bFunctionSubClass
      369 => x"00",  -- bFunctionProtocol
      370 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
      371 => x"09",  -- bLength
      372 => x"04",  -- bDescriptorType
      373 => x"00",  -- bInterfaceNumber
      374 => x"00",  -- bAlternateSetting
      375 => x"01",  -- bNumEndpoints
      376 => x"02",  -- bInterfaceClass
      377 => x"02",  -- bInterfaceSubClass
      378 => x"00",  -- bInterfaceProtocol
      379 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      380 => x"05",  -- bLength
      381 => x"24",  -- bDescriptorType
      382 => x"00",  -- bDescriptorSubtype
      383 => x"20",  -- bcdCDC
      384 => x"01",
      -- Usb2CDCFuncCallManagementDesc
      385 => x"05",  -- bLength
      386 => x"24",  -- bDescriptorType
      387 => x"01",  -- bDescriptorSubtype
      388 => x"00",  -- bmCapabilities
      389 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
      390 => x"04",  -- bLength
      391 => x"24",  -- bDescriptorType
      392 => x"02",  -- bDescriptorSubtype
      393 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
      394 => x"05",  -- bLength
      395 => x"24",  -- bDescriptorType
      396 => x"06",  -- bDescriptorSubtype
      397 => x"00",  -- bControlInterface
      398 => x"01",
      -- Usb2EndpointDesc
      399 => x"07",  -- bLength
      400 => x"05",  -- bDescriptorType
      401 => x"82",  -- bEndpointAddress
      402 => x"03",  -- bmAttributes
      403 => x"08",  -- wMaxPacketSize
      404 => x"00",
      405 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      406 => x"09",  -- bLength
      407 => x"04",  -- bDescriptorType
      408 => x"01",  -- bInterfaceNumber
      409 => x"00",  -- bAlternateSetting
      410 => x"02",  -- bNumEndpoints
      411 => x"0a",  -- bInterfaceClass
      412 => x"00",  -- bInterfaceSubClass
      413 => x"00",  -- bInterfaceProtocol
      414 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      415 => x"07",  -- bLength
      416 => x"05",  -- bDescriptorType
      417 => x"81",  -- bEndpointAddress
      418 => x"02",  -- bmAttributes
      419 => x"00",  -- wMaxPacketSize
      420 => x"02",
      421 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      422 => x"07",  -- bLength
      423 => x"05",  -- bDescriptorType
      424 => x"01",  -- bEndpointAddress
      425 => x"02",  -- bmAttributes
      426 => x"00",  -- wMaxPacketSize
      427 => x"02",
      428 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      429 => x"08",  -- bLength
      430 => x"0b",  -- bDescriptorType
      431 => x"02",  -- bFirstInterface
      432 => x"02",  -- bInterfaceCount
      433 => x"01",  -- bFunctionClass
      434 => x"00",  -- bFunctionSubClass
      435 => x"20",  -- bFunctionProtocol
      436 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      437 => x"09",  -- bLength
      438 => x"04",  -- bDescriptorType
      439 => x"02",  -- bInterfaceNumber
      440 => x"00",  -- bAlternateSetting
      441 => x"00",  -- bNumEndpoints
      442 => x"01",  -- bInterfaceClass
      443 => x"01",  -- bInterfaceSubClass
      444 => x"20",  -- bInterfaceProtocol
      445 => x"00",  -- iInterface
      -- Usb2UAC2FuncHeaderDesc
      446 => x"09",  -- bLength
      447 => x"24",  -- bDescriptorType
      448 => x"01",  -- bDescriptorSubtype
      449 => x"00",  -- bcdADC
      450 => x"02",
      451 => x"03",  -- bCategory
      452 => x"40",  -- wTotalLength
      453 => x"00",
      454 => x"00",  -- bmControls
      -- Usb2UAC2ClockSourceDesc
      455 => x"08",  -- bLength
      456 => x"24",  -- bDescriptorType
      457 => x"0a",  -- bDescriptorSubtype
      458 => x"09",  -- bClockID
      459 => x"00",  -- bmAttributes
      460 => x"01",  -- bmControls
      461 => x"00",  -- bAssocTerminal
      462 => x"00",  -- iClockSource
      -- Usb2UAC2InputTerminalDesc
      463 => x"11",  -- bLength
      464 => x"24",  -- bDescriptorType
      465 => x"02",  -- bDescriptorSubtype
      466 => x"01",  -- bTerminalID
      467 => x"01",  -- wTerminalType
      468 => x"02",
      469 => x"00",  -- bAssocTerminal
      470 => x"09",  -- bCSourceID
      471 => x"02",  -- bNrChannels
      472 => x"03",  -- bmChannelConfig
      473 => x"00",
      474 => x"00",
      475 => x"00",
      476 => x"00",  -- iChannelNames
      477 => x"00",  -- bmControls
      478 => x"00",
      479 => x"00",  -- iTerminal
      -- Usb2UAC2StereoFeatureUnitDesc
      480 => x"12",  -- bLength
      481 => x"24",  -- bDescriptorType
      482 => x"06",  -- bDescriptorSubtype
      483 => x"02",  -- bUnitID
      484 => x"01",  -- bSourceID
      485 => x"0f",  -- bmaControls0
      486 => x"00",
      487 => x"00",
      488 => x"00",
      489 => x"0f",  -- bmaControls1
      490 => x"00",
      491 => x"00",
      492 => x"00",
      493 => x"0f",  -- bmaControls2
      494 => x"00",
      495 => x"00",
      496 => x"00",
      497 => x"00",  -- iFeature
      -- Usb2UAC2OutputTerminalDesc
      498 => x"0c",  -- bLength
      499 => x"24",  -- bDescriptorType
      500 => x"03",  -- bDescriptorSubtype
      501 => x"03",  -- bTerminalID
      502 => x"01",  -- wTerminalType
      503 => x"01",
      504 => x"00",  -- bAssocTerminal
      505 => x"02",  -- bSourceID
      506 => x"09",  -- bCSourceID
      507 => x"00",  -- bmControls
      508 => x"00",
      509 => x"00",  -- iTerminal
      -- Usb2InterfaceDesc
      510 => x"09",  -- bLength
      511 => x"04",  -- bDescriptorType
      512 => x"03",  -- bInterfaceNumber
      513 => x"00",  -- bAlternateSetting
      514 => x"00",  -- bNumEndpoints
      515 => x"01",  -- bInterfaceClass
      516 => x"02",  -- bInterfaceSubClass
      517 => x"20",  -- bInterfaceProtocol
      518 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      519 => x"09",  -- bLength
      520 => x"04",  -- bDescriptorType
      521 => x"03",  -- bInterfaceNumber
      522 => x"01",  -- bAlternateSetting
      523 => x"01",  -- bNumEndpoints
      524 => x"01",  -- bInterfaceClass
      525 => x"02",  -- bInterfaceSubClass
      526 => x"20",  -- bInterfaceProtocol
      527 => x"00",  -- iInterface
      -- Usb2UAC2ClassSpecificASInterfaceDesc
      528 => x"10",  -- bLength
      529 => x"24",  -- bDescriptorType
      530 => x"01",  -- bDescriptorSubtype
      531 => x"03",  -- bTerminalLink
      532 => x"00",  -- bmControls
      533 => x"01",  -- bFormatType
      534 => x"01",  -- bmFormats
      535 => x"00",
      536 => x"00",
      537 => x"00",
      538 => x"02",  -- bNrChannels
      539 => x"03",  -- bmChannelConfig
      540 => x"00",
      541 => x"00",
      542 => x"00",
      543 => x"00",  -- iChannelNames
      -- Usb2UAC2FormatType1Desc
      544 => x"06",  -- bLength
      545 => x"24",  -- bDescriptorType
      546 => x"02",  -- bDescriptorSubtype
      547 => x"01",  -- bFormatType
      548 => x"03",  -- bSubslotSize
      549 => x"18",  -- bBitResolution
      -- Usb2EndpointDesc
      550 => x"07",  -- bLength
      551 => x"05",  -- bDescriptorType
      552 => x"83",  -- bEndpointAddress
      553 => x"05",  -- bmAttributes
      554 => x"26",  -- wMaxPacketSize
      555 => x"01",
      556 => x"04",  -- bInterval
      -- Usb2UAC2ASISOEndpointDesc
      557 => x"08",  -- bLength
      558 => x"25",  -- bDescriptorType
      559 => x"01",  -- bDescriptorSubtype
      560 => x"00",  -- bmAttributes
      561 => x"00",  -- bmControls
      562 => x"00",  -- bLockDelayUnits
      563 => x"00",  -- wLockDelay
      564 => x"00",
      -- Usb2InterfaceAssociationDesc
      565 => x"08",  -- bLength
      566 => x"0b",  -- bDescriptorType
      567 => x"04",  -- bFirstInterface
      568 => x"02",  -- bInterfaceCount
      569 => x"02",  -- bFunctionClass
      570 => x"0d",  -- bFunctionSubClass
      571 => x"00",  -- bFunctionProtocol
      572 => x"04",  -- iFunction
      -- Usb2InterfaceDesc
      573 => x"09",  -- bLength
      574 => x"04",  -- bDescriptorType
      575 => x"04",  -- bInterfaceNumber
      576 => x"00",  -- bAlternateSetting
      577 => x"01",  -- bNumEndpoints
      578 => x"02",  -- bInterfaceClass
      579 => x"0d",  -- bInterfaceSubClass
      580 => x"00",  -- bInterfaceProtocol
      581 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      582 => x"05",  -- bLength
      583 => x"24",  -- bDescriptorType
      584 => x"00",  -- bDescriptorSubtype
      585 => x"20",  -- bcdCDC
      586 => x"01",
      -- Usb2CDCFuncUnionDesc
      587 => x"05",  -- bLength
      588 => x"24",  -- bDescriptorType
      589 => x"06",  -- bDescriptorSubtype
      590 => x"04",  -- bControlInterface
      591 => x"05",
      -- Usb2CDCFuncEthernetDesc
      592 => x"0d",  -- bLength
      593 => x"24",  -- bDescriptorType
      594 => x"0f",  -- bDescriptorSubtype
      595 => x"05",  -- iMACAddress
      596 => x"00",  -- bmEthernetStatistics
      597 => x"00",
      598 => x"00",
      599 => x"00",
      600 => x"ea",  -- wMaxSegmentSize
      601 => x"05",
      602 => x"20",  -- wNumberMCFilters
      603 => x"80",
      604 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      605 => x"06",  -- bLength
      606 => x"24",  -- bDescriptorType
      607 => x"1a",  -- bDescriptorSubtype
      608 => x"00",  -- bcdNcmVersion
      609 => x"01",
      610 => x"03",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      611 => x"07",  -- bLength
      612 => x"05",  -- bDescriptorType
      613 => x"85",  -- bEndpointAddress
      614 => x"03",  -- bmAttributes
      615 => x"10",  -- wMaxPacketSize
      616 => x"00",
      617 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      618 => x"09",  -- bLength
      619 => x"04",  -- bDescriptorType
      620 => x"05",  -- bInterfaceNumber
      621 => x"00",  -- bAlternateSetting
      622 => x"00",  -- bNumEndpoints
      623 => x"0a",  -- bInterfaceClass
      624 => x"00",  -- bInterfaceSubClass
      625 => x"01",  -- bInterfaceProtocol
      626 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      627 => x"09",  -- bLength
      628 => x"04",  -- bDescriptorType
      629 => x"05",  -- bInterfaceNumber
      630 => x"01",  -- bAlternateSetting
      631 => x"02",  -- bNumEndpoints
      632 => x"0a",  -- bInterfaceClass
      633 => x"00",  -- bInterfaceSubClass
      634 => x"01",  -- bInterfaceProtocol
      635 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      636 => x"07",  -- bLength
      637 => x"05",  -- bDescriptorType
      638 => x"84",  -- bEndpointAddress
      639 => x"02",  -- bmAttributes
      640 => x"00",  -- wMaxPacketSize
      641 => x"02",
      642 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      643 => x"07",  -- bLength
      644 => x"05",  -- bDescriptorType
      645 => x"04",  -- bEndpointAddress
      646 => x"02",  -- bmAttributes
      647 => x"00",  -- wMaxPacketSize
      648 => x"02",
      649 => x"00",  -- bInterval
      -- Usb2StringDesc
      650 => x"04",  -- bLength
      651 => x"03",  -- bDescriptorType
      652 => x"09",  -- langID 0x0409
      653 => x"04",
      -- Usb2StringDesc
      654 => x"46",  -- bLength
      655 => x"03",  -- bDescriptorType
      656 => x"54",  -- T
      657 => x"00",
      658 => x"69",  -- i
      659 => x"00",
      660 => x"6c",  -- l
      661 => x"00",
      662 => x"6c",  -- l
      663 => x"00",
      664 => x"27",  -- '
      665 => x"00",
      666 => x"73",  -- s
      667 => x"00",
      668 => x"20",  --  
      669 => x"00",
      670 => x"4d",  -- M
      671 => x"00",
      672 => x"65",  -- e
      673 => x"00",
      674 => x"63",  -- c
      675 => x"00",
      676 => x"61",  -- a
      677 => x"00",
      678 => x"74",  -- t
      679 => x"00",
      680 => x"69",  -- i
      681 => x"00",
      682 => x"63",  -- c
      683 => x"00",
      684 => x"61",  -- a
      685 => x"00",
      686 => x"20",  --  
      687 => x"00",
      688 => x"55",  -- U
      689 => x"00",
      690 => x"53",  -- S
      691 => x"00",
      692 => x"42",  -- B
      693 => x"00",
      694 => x"20",  --  
      695 => x"00",
      696 => x"45",  -- E
      697 => x"00",
      698 => x"78",  -- x
      699 => x"00",
      700 => x"61",  -- a
      701 => x"00",
      702 => x"6d",  -- m
      703 => x"00",
      704 => x"70",  -- p
      705 => x"00",
      706 => x"6c",  -- l
      707 => x"00",
      708 => x"65",  -- e
      709 => x"00",
      710 => x"20",  --  
      711 => x"00",
      712 => x"44",  -- D
      713 => x"00",
      714 => x"65",  -- e
      715 => x"00",
      716 => x"76",  -- v
      717 => x"00",
      718 => x"69",  -- i
      719 => x"00",
      720 => x"63",  -- c
      721 => x"00",
      722 => x"65",  -- e
      723 => x"00",
      -- Usb2StringDesc
      724 => x"1a",  -- bLength
      725 => x"03",  -- bDescriptorType
      726 => x"4d",  -- M
      727 => x"00",
      728 => x"65",  -- e
      729 => x"00",
      730 => x"63",  -- c
      731 => x"00",
      732 => x"61",  -- a
      733 => x"00",
      734 => x"74",  -- t
      735 => x"00",
      736 => x"69",  -- i
      737 => x"00",
      738 => x"63",  -- c
      739 => x"00",
      740 => x"61",  -- a
      741 => x"00",
      742 => x"20",  --  
      743 => x"00",
      744 => x"41",  -- A
      745 => x"00",
      746 => x"43",  -- C
      747 => x"00",
      748 => x"4d",  -- M
      749 => x"00",
      -- Usb2StringDesc
      750 => x"32",  -- bLength
      751 => x"03",  -- bDescriptorType
      752 => x"4d",  -- M
      753 => x"00",
      754 => x"65",  -- e
      755 => x"00",
      756 => x"63",  -- c
      757 => x"00",
      758 => x"61",  -- a
      759 => x"00",
      760 => x"74",  -- t
      761 => x"00",
      762 => x"69",  -- i
      763 => x"00",
      764 => x"63",  -- c
      765 => x"00",
      766 => x"61",  -- a
      767 => x"00",
      768 => x"20",  --  
      769 => x"00",
      770 => x"55",  -- U
      771 => x"00",
      772 => x"41",  -- A
      773 => x"00",
      774 => x"43",  -- C
      775 => x"00",
      776 => x"32",  -- 2
      777 => x"00",
      778 => x"20",  --  
      779 => x"00",
      780 => x"4d",  -- M
      781 => x"00",
      782 => x"69",  -- i
      783 => x"00",
      784 => x"63",  -- c
      785 => x"00",
      786 => x"72",  -- r
      787 => x"00",
      788 => x"6f",  -- o
      789 => x"00",
      790 => x"70",  -- p
      791 => x"00",
      792 => x"68",  -- h
      793 => x"00",
      794 => x"6f",  -- o
      795 => x"00",
      796 => x"6e",  -- n
      797 => x"00",
      798 => x"65",  -- e
      799 => x"00",
      -- Usb2StringDesc
      800 => x"1a",  -- bLength
      801 => x"03",  -- bDescriptorType
      802 => x"4d",  -- M
      803 => x"00",
      804 => x"65",  -- e
      805 => x"00",
      806 => x"63",  -- c
      807 => x"00",
      808 => x"61",  -- a
      809 => x"00",
      810 => x"74",  -- t
      811 => x"00",
      812 => x"69",  -- i
      813 => x"00",
      814 => x"63",  -- c
      815 => x"00",
      816 => x"61",  -- a
      817 => x"00",
      818 => x"20",  --  
      819 => x"00",
      820 => x"4e",  -- N
      821 => x"00",
      822 => x"43",  -- C
      823 => x"00",
      824 => x"4d",  -- M
      825 => x"00",
      -- Usb2StringDesc
      826 => x"1a",  -- bLength
      827 => x"03",  -- bDescriptorType
      828 => x"30",  -- 0
      829 => x"00",
      830 => x"32",  -- 2
      831 => x"00",
      832 => x"64",  -- d
      833 => x"00",
      834 => x"65",  -- e
      835 => x"00",
      836 => x"61",  -- a
      837 => x"00",
      838 => x"64",  -- d
      839 => x"00",
      840 => x"62",  -- b
      841 => x"00",
      842 => x"65",  -- e
      843 => x"00",
      844 => x"65",  -- e
      845 => x"00",
      846 => x"66",  -- f
      847 => x"00",
      848 => x"33",  -- 3
      849 => x"00",
      850 => x"31",  -- 1
      851 => x"00",
      -- Usb2SentinelDesc
      852 => x"02",  -- bLength
      853 => x"ff"   -- bDescriptorType
      );
   begin
      return c;
   end function usb2AppGetDescriptors;

   constant USB2_APP_DESCRIPTORS_C : Usb2ByteArray := usb2AppGetDescriptors;

end package body Usb2AppCfgPkg;
