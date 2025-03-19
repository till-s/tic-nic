-- Copyright Till Straumann, 2023. Licensed under the EUPL-1.2 or later.
-- You may obtain a copy of the license at
--   https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
-- This notice must not be removed.

-- THIS FILE WAS AUTOMATICALLY GENERATED; DO NOT EDIT!

-- Generated with: 'genAppCfgPkgBody.py -f AppCfgPkgBody.vhd tic_nic.yaml':
--
-- deviceDesc:
--   configurationDesc:
--     functionACM:
--       enabled: true
--       iFunction: Mecatica ACM
--     functionNCM:
--       enabled: true
--       haveDynamicMACAddress: true
--       iFunction: Mecatica NCM
--       iMACAddress: 02deadbeef31
--       numMulticastFilters: 32800
--   iProduct: Till's PTP TicNic Ethernet Adapter
--   idProduct: 34897
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
       10 => x"51",  -- idProduct
       11 => x"88",
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
       30 => x"a0",  -- wTotalLength
       31 => x"00",
       32 => x"04",  -- bNumInterfaces
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
      107 => x"02",  -- bFunctionClass
      108 => x"0d",  -- bFunctionSubClass
      109 => x"00",  -- bFunctionProtocol
      110 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      111 => x"09",  -- bLength
      112 => x"04",  -- bDescriptorType
      113 => x"02",  -- bInterfaceNumber
      114 => x"00",  -- bAlternateSetting
      115 => x"01",  -- bNumEndpoints
      116 => x"02",  -- bInterfaceClass
      117 => x"0d",  -- bInterfaceSubClass
      118 => x"00",  -- bInterfaceProtocol
      119 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      120 => x"05",  -- bLength
      121 => x"24",  -- bDescriptorType
      122 => x"00",  -- bDescriptorSubtype
      123 => x"20",  -- bcdCDC
      124 => x"01",
      -- Usb2CDCFuncUnionDesc
      125 => x"05",  -- bLength
      126 => x"24",  -- bDescriptorType
      127 => x"06",  -- bDescriptorSubtype
      128 => x"02",  -- bControlInterface
      129 => x"03",
      -- Usb2CDCFuncEthernetDesc
      130 => x"0d",  -- bLength
      131 => x"24",  -- bDescriptorType
      132 => x"0f",  -- bDescriptorSubtype
      133 => x"04",  -- iMACAddress
      134 => x"00",  -- bmEthernetStatistics
      135 => x"00",
      136 => x"00",
      137 => x"00",
      138 => x"ea",  -- wMaxSegmentSize
      139 => x"05",
      140 => x"20",  -- wNumberMCFilters
      141 => x"80",
      142 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      143 => x"06",  -- bLength
      144 => x"24",  -- bDescriptorType
      145 => x"1a",  -- bDescriptorSubtype
      146 => x"00",  -- bcdNcmVersion
      147 => x"01",
      148 => x"03",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      149 => x"07",  -- bLength
      150 => x"05",  -- bDescriptorType
      151 => x"84",  -- bEndpointAddress
      152 => x"03",  -- bmAttributes
      153 => x"10",  -- wMaxPacketSize
      154 => x"00",
      155 => x"10",  -- bInterval
      -- Usb2InterfaceDesc
      156 => x"09",  -- bLength
      157 => x"04",  -- bDescriptorType
      158 => x"03",  -- bInterfaceNumber
      159 => x"00",  -- bAlternateSetting
      160 => x"00",  -- bNumEndpoints
      161 => x"0a",  -- bInterfaceClass
      162 => x"00",  -- bInterfaceSubClass
      163 => x"01",  -- bInterfaceProtocol
      164 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      165 => x"09",  -- bLength
      166 => x"04",  -- bDescriptorType
      167 => x"03",  -- bInterfaceNumber
      168 => x"01",  -- bAlternateSetting
      169 => x"02",  -- bNumEndpoints
      170 => x"0a",  -- bInterfaceClass
      171 => x"00",  -- bInterfaceSubClass
      172 => x"01",  -- bInterfaceProtocol
      173 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      174 => x"07",  -- bLength
      175 => x"05",  -- bDescriptorType
      176 => x"83",  -- bEndpointAddress
      177 => x"02",  -- bmAttributes
      178 => x"40",  -- wMaxPacketSize
      179 => x"00",
      180 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      181 => x"07",  -- bLength
      182 => x"05",  -- bDescriptorType
      183 => x"03",  -- bEndpointAddress
      184 => x"02",  -- bmAttributes
      185 => x"40",  -- wMaxPacketSize
      186 => x"00",
      187 => x"00",  -- bInterval
      -- Usb2SentinelDesc
      188 => x"02",  -- bLength
      189 => x"ff",  -- bDescriptorType
      -- Usb2DeviceDesc
      190 => x"12",  -- bLength
      191 => x"01",  -- bDescriptorType
      192 => x"00",  -- bcdUSB
      193 => x"02",
      194 => x"ef",  -- bDeviceClass
      195 => x"02",  -- bDeviceSubClass
      196 => x"01",  -- bDeviceProtocol
      197 => x"40",  -- bMaxPacketSize0
      198 => x"09",  -- idVendor
      199 => x"12",
      200 => x"51",  -- idProduct
      201 => x"88",
      202 => x"00",  -- bcdDevice
      203 => x"01",
      204 => x"00",  -- iManufacturer
      205 => x"01",  -- iProduct
      206 => x"00",  -- iSerialNumber
      207 => x"01",  -- bNumConfigurations
      -- Usb2Device_QualifierDesc
      208 => x"0a",  -- bLength
      209 => x"06",  -- bDescriptorType
      210 => x"00",  -- bcdUSB
      211 => x"02",
      212 => x"ef",  -- bDeviceClass
      213 => x"02",  -- bDeviceSubClass
      214 => x"01",  -- bDeviceProtocol
      215 => x"40",  -- bMaxPacketSize0
      216 => x"01",  -- bNumConfigurations
      217 => x"00",  -- bReserved
      -- Usb2ConfigurationDesc
      218 => x"09",  -- bLength
      219 => x"02",  -- bDescriptorType
      220 => x"a0",  -- wTotalLength
      221 => x"00",
      222 => x"04",  -- bNumInterfaces
      223 => x"01",  -- bConfigurationValue
      224 => x"00",  -- iConfiguration
      225 => x"a0",  -- bmAttributes
      226 => x"32",  -- bMaxPower
      -- Usb2InterfaceAssociationDesc
      227 => x"08",  -- bLength
      228 => x"0b",  -- bDescriptorType
      229 => x"00",  -- bFirstInterface
      230 => x"02",  -- bInterfaceCount
      231 => x"02",  -- bFunctionClass
      232 => x"02",  -- bFunctionSubClass
      233 => x"00",  -- bFunctionProtocol
      234 => x"02",  -- iFunction
      -- Usb2InterfaceDesc
      235 => x"09",  -- bLength
      236 => x"04",  -- bDescriptorType
      237 => x"00",  -- bInterfaceNumber
      238 => x"00",  -- bAlternateSetting
      239 => x"01",  -- bNumEndpoints
      240 => x"02",  -- bInterfaceClass
      241 => x"02",  -- bInterfaceSubClass
      242 => x"00",  -- bInterfaceProtocol
      243 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      244 => x"05",  -- bLength
      245 => x"24",  -- bDescriptorType
      246 => x"00",  -- bDescriptorSubtype
      247 => x"20",  -- bcdCDC
      248 => x"01",
      -- Usb2CDCFuncCallManagementDesc
      249 => x"05",  -- bLength
      250 => x"24",  -- bDescriptorType
      251 => x"01",  -- bDescriptorSubtype
      252 => x"00",  -- bmCapabilities
      253 => x"01",  -- bDataInterface
      -- Usb2CDCFuncACMDesc
      254 => x"04",  -- bLength
      255 => x"24",  -- bDescriptorType
      256 => x"02",  -- bDescriptorSubtype
      257 => x"06",  -- bmCapabilities
      -- Usb2CDCFuncUnionDesc
      258 => x"05",  -- bLength
      259 => x"24",  -- bDescriptorType
      260 => x"06",  -- bDescriptorSubtype
      261 => x"00",  -- bControlInterface
      262 => x"01",
      -- Usb2EndpointDesc
      263 => x"07",  -- bLength
      264 => x"05",  -- bDescriptorType
      265 => x"82",  -- bEndpointAddress
      266 => x"03",  -- bmAttributes
      267 => x"08",  -- wMaxPacketSize
      268 => x"00",
      269 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      270 => x"09",  -- bLength
      271 => x"04",  -- bDescriptorType
      272 => x"01",  -- bInterfaceNumber
      273 => x"00",  -- bAlternateSetting
      274 => x"02",  -- bNumEndpoints
      275 => x"0a",  -- bInterfaceClass
      276 => x"00",  -- bInterfaceSubClass
      277 => x"00",  -- bInterfaceProtocol
      278 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      279 => x"07",  -- bLength
      280 => x"05",  -- bDescriptorType
      281 => x"81",  -- bEndpointAddress
      282 => x"02",  -- bmAttributes
      283 => x"00",  -- wMaxPacketSize
      284 => x"02",
      285 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      286 => x"07",  -- bLength
      287 => x"05",  -- bDescriptorType
      288 => x"01",  -- bEndpointAddress
      289 => x"02",  -- bmAttributes
      290 => x"00",  -- wMaxPacketSize
      291 => x"02",
      292 => x"00",  -- bInterval
      -- Usb2InterfaceAssociationDesc
      293 => x"08",  -- bLength
      294 => x"0b",  -- bDescriptorType
      295 => x"02",  -- bFirstInterface
      296 => x"02",  -- bInterfaceCount
      297 => x"02",  -- bFunctionClass
      298 => x"0d",  -- bFunctionSubClass
      299 => x"00",  -- bFunctionProtocol
      300 => x"03",  -- iFunction
      -- Usb2InterfaceDesc
      301 => x"09",  -- bLength
      302 => x"04",  -- bDescriptorType
      303 => x"02",  -- bInterfaceNumber
      304 => x"00",  -- bAlternateSetting
      305 => x"01",  -- bNumEndpoints
      306 => x"02",  -- bInterfaceClass
      307 => x"0d",  -- bInterfaceSubClass
      308 => x"00",  -- bInterfaceProtocol
      309 => x"00",  -- iInterface
      -- Usb2CDCFuncHeaderDesc
      310 => x"05",  -- bLength
      311 => x"24",  -- bDescriptorType
      312 => x"00",  -- bDescriptorSubtype
      313 => x"20",  -- bcdCDC
      314 => x"01",
      -- Usb2CDCFuncUnionDesc
      315 => x"05",  -- bLength
      316 => x"24",  -- bDescriptorType
      317 => x"06",  -- bDescriptorSubtype
      318 => x"02",  -- bControlInterface
      319 => x"03",
      -- Usb2CDCFuncEthernetDesc
      320 => x"0d",  -- bLength
      321 => x"24",  -- bDescriptorType
      322 => x"0f",  -- bDescriptorSubtype
      323 => x"04",  -- iMACAddress
      324 => x"00",  -- bmEthernetStatistics
      325 => x"00",
      326 => x"00",
      327 => x"00",
      328 => x"ea",  -- wMaxSegmentSize
      329 => x"05",
      330 => x"20",  -- wNumberMCFilters
      331 => x"80",
      332 => x"00",  -- bNumberPowerFilters
      -- Usb2CDCFuncNCMDesc
      333 => x"06",  -- bLength
      334 => x"24",  -- bDescriptorType
      335 => x"1a",  -- bDescriptorSubtype
      336 => x"00",  -- bcdNcmVersion
      337 => x"01",
      338 => x"03",  -- bmNetworkCapabilities
      -- Usb2EndpointDesc
      339 => x"07",  -- bLength
      340 => x"05",  -- bDescriptorType
      341 => x"84",  -- bEndpointAddress
      342 => x"03",  -- bmAttributes
      343 => x"10",  -- wMaxPacketSize
      344 => x"00",
      345 => x"08",  -- bInterval
      -- Usb2InterfaceDesc
      346 => x"09",  -- bLength
      347 => x"04",  -- bDescriptorType
      348 => x"03",  -- bInterfaceNumber
      349 => x"00",  -- bAlternateSetting
      350 => x"00",  -- bNumEndpoints
      351 => x"0a",  -- bInterfaceClass
      352 => x"00",  -- bInterfaceSubClass
      353 => x"01",  -- bInterfaceProtocol
      354 => x"00",  -- iInterface
      -- Usb2InterfaceDesc
      355 => x"09",  -- bLength
      356 => x"04",  -- bDescriptorType
      357 => x"03",  -- bInterfaceNumber
      358 => x"01",  -- bAlternateSetting
      359 => x"02",  -- bNumEndpoints
      360 => x"0a",  -- bInterfaceClass
      361 => x"00",  -- bInterfaceSubClass
      362 => x"01",  -- bInterfaceProtocol
      363 => x"00",  -- iInterface
      -- Usb2EndpointDesc
      364 => x"07",  -- bLength
      365 => x"05",  -- bDescriptorType
      366 => x"83",  -- bEndpointAddress
      367 => x"02",  -- bmAttributes
      368 => x"00",  -- wMaxPacketSize
      369 => x"02",
      370 => x"00",  -- bInterval
      -- Usb2EndpointDesc
      371 => x"07",  -- bLength
      372 => x"05",  -- bDescriptorType
      373 => x"03",  -- bEndpointAddress
      374 => x"02",  -- bmAttributes
      375 => x"00",  -- wMaxPacketSize
      376 => x"02",
      377 => x"00",  -- bInterval
      -- Usb2StringDesc
      378 => x"04",  -- bLength
      379 => x"03",  -- bDescriptorType
      380 => x"09",  -- langID 0x0409
      381 => x"04",
      -- Usb2StringDesc
      382 => x"46",  -- bLength
      383 => x"03",  -- bDescriptorType
      384 => x"54",  -- T
      385 => x"00",
      386 => x"69",  -- i
      387 => x"00",
      388 => x"6c",  -- l
      389 => x"00",
      390 => x"6c",  -- l
      391 => x"00",
      392 => x"27",  -- '
      393 => x"00",
      394 => x"73",  -- s
      395 => x"00",
      396 => x"20",  --  
      397 => x"00",
      398 => x"50",  -- P
      399 => x"00",
      400 => x"54",  -- T
      401 => x"00",
      402 => x"50",  -- P
      403 => x"00",
      404 => x"20",  --  
      405 => x"00",
      406 => x"54",  -- T
      407 => x"00",
      408 => x"69",  -- i
      409 => x"00",
      410 => x"63",  -- c
      411 => x"00",
      412 => x"4e",  -- N
      413 => x"00",
      414 => x"69",  -- i
      415 => x"00",
      416 => x"63",  -- c
      417 => x"00",
      418 => x"20",  --  
      419 => x"00",
      420 => x"45",  -- E
      421 => x"00",
      422 => x"74",  -- t
      423 => x"00",
      424 => x"68",  -- h
      425 => x"00",
      426 => x"65",  -- e
      427 => x"00",
      428 => x"72",  -- r
      429 => x"00",
      430 => x"6e",  -- n
      431 => x"00",
      432 => x"65",  -- e
      433 => x"00",
      434 => x"74",  -- t
      435 => x"00",
      436 => x"20",  --  
      437 => x"00",
      438 => x"41",  -- A
      439 => x"00",
      440 => x"64",  -- d
      441 => x"00",
      442 => x"61",  -- a
      443 => x"00",
      444 => x"70",  -- p
      445 => x"00",
      446 => x"74",  -- t
      447 => x"00",
      448 => x"65",  -- e
      449 => x"00",
      450 => x"72",  -- r
      451 => x"00",
      -- Usb2StringDesc
      452 => x"1a",  -- bLength
      453 => x"03",  -- bDescriptorType
      454 => x"4d",  -- M
      455 => x"00",
      456 => x"65",  -- e
      457 => x"00",
      458 => x"63",  -- c
      459 => x"00",
      460 => x"61",  -- a
      461 => x"00",
      462 => x"74",  -- t
      463 => x"00",
      464 => x"69",  -- i
      465 => x"00",
      466 => x"63",  -- c
      467 => x"00",
      468 => x"61",  -- a
      469 => x"00",
      470 => x"20",  --  
      471 => x"00",
      472 => x"41",  -- A
      473 => x"00",
      474 => x"43",  -- C
      475 => x"00",
      476 => x"4d",  -- M
      477 => x"00",
      -- Usb2StringDesc
      478 => x"1a",  -- bLength
      479 => x"03",  -- bDescriptorType
      480 => x"4d",  -- M
      481 => x"00",
      482 => x"65",  -- e
      483 => x"00",
      484 => x"63",  -- c
      485 => x"00",
      486 => x"61",  -- a
      487 => x"00",
      488 => x"74",  -- t
      489 => x"00",
      490 => x"69",  -- i
      491 => x"00",
      492 => x"63",  -- c
      493 => x"00",
      494 => x"61",  -- a
      495 => x"00",
      496 => x"20",  --  
      497 => x"00",
      498 => x"4e",  -- N
      499 => x"00",
      500 => x"43",  -- C
      501 => x"00",
      502 => x"4d",  -- M
      503 => x"00",
      -- Usb2StringDesc
      504 => x"1a",  -- bLength
      505 => x"03",  -- bDescriptorType
      506 => x"30",  -- 0
      507 => x"00",
      508 => x"32",  -- 2
      509 => x"00",
      510 => x"64",  -- d
      511 => x"00",
      512 => x"65",  -- e
      513 => x"00",
      514 => x"61",  -- a
      515 => x"00",
      516 => x"64",  -- d
      517 => x"00",
      518 => x"62",  -- b
      519 => x"00",
      520 => x"65",  -- e
      521 => x"00",
      522 => x"65",  -- e
      523 => x"00",
      524 => x"66",  -- f
      525 => x"00",
      526 => x"33",  -- 3
      527 => x"00",
      528 => x"31",  -- 1
      529 => x"00",
      -- Usb2SentinelDesc
      530 => x"02",  -- bLength
      531 => x"ff"   -- bDescriptorType
      );
   begin
      return c;
   end function usb2AppGetDescriptors;

   constant USB2_APP_DESCRIPTORS_C : Usb2ByteArray := usb2AppGetDescriptors;

end package body Usb2AppCfgPkg;
