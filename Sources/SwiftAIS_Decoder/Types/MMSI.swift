//
//  MMSI.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

struct MMSI {
    var value: UInt32
    
    init?(value: UInt32) {
        guard value <= 0b111011100110101100100111111111 else { return nil } // 999 999 999
        self.value = value
    }
    
    var description: String {
        return String(format: "%09u", value)
    }

    /// The country or territory allocated to this MMSI's Maritime Identification Digits (the first three digits).
    /// Sourced from `description` so leading zeroes are preserved. Returns "Unknown" if the MID is unallocated.
    var country: String {
        guard let mid = UInt16(description.prefix(3)),
              let areaCode = AreaCode(rawValue: mid) else {
            return "Unknown"
        }
        return areaCode.description
    }
}

/// Maritime Identification Digits (MID) — the first three digits of an MMSI,
/// identifying the country or territory of the vessel's registration.
///
/// Source: ITU Table of Maritime Identification Digits.
enum AreaCode: UInt16 {
    case international = 1
    case albania = 201
    case andorra = 202
    case austria = 203
    case portugalAzores = 204
    case belgium = 205
    case belarus = 206
    case bulgaria = 207
    case vaticanCityState = 208
    case cyprus209 = 209
    case cyprus210 = 210
    case germany211 = 211
    case cyprus212 = 212
    case georgia = 213
    case moldova = 214
    case malta215 = 215
    case armenia = 216
    case germany218 = 218
    case denmark219 = 219
    case denmark220 = 220
    case spain224 = 224
    case spain225 = 225
    case france226 = 226
    case france227 = 227
    case france228 = 228
    case malta229 = 229
    case finland = 230
    case denmarkFaroeIslands = 231
    case unitedKingdom232 = 232
    case unitedKingdom233 = 233
    case unitedKingdom234 = 234
    case unitedKingdom235 = 235
    case unitedKingdomGibraltar = 236
    case greece237 = 237
    case croatia = 238
    case greece239 = 239
    case greece240 = 240
    case greece241 = 241
    case morocco = 242
    case hungary = 243
    case netherlands244 = 244
    case netherlands245 = 245
    case netherlands246 = 246
    case italy = 247
    case malta248 = 248
    case malta249 = 249
    case ireland = 250
    case iceland = 251
    case liechtenstein = 252
    case luxembourg = 253
    case monaco = 254
    case portugalMadeira = 255
    case malta256 = 256
    case norway257 = 257
    case norway258 = 258
    case norway259 = 259
    case poland = 261
    case montenegro = 262
    case portugal = 263
    case romania = 264
    case sweden265 = 265
    case sweden266 = 266
    case slovakRepublic = 267
    case sanMarino = 268
    case switzerland = 269
    case czechRepublic = 270
    case republicOfTurkiye = 271
    case ukraine = 272
    case russianFederation = 273
    case northMacedonia = 274
    case latvia = 275
    case estonia = 276
    case lithuania = 277
    case slovenia = 278
    case serbia = 279
    case unitedKingdomAnguilla = 301
    case unitedStatesAlaska = 303
    case antiguaAndBarbuda304 = 304
    case antiguaAndBarbuda305 = 305
    case netherlandsBonaireSintEustatiusAndSabaCuracaoSintMaarten = 306
    case netherlandsAruba = 307
    case bahamas308 = 308
    case bahamas309 = 309
    case unitedKingdomBermuda = 310
    case bahamas311 = 311
    case belize = 312
    case barbados = 314
    case canada = 316
    case unitedKingdomCaymanIslands = 319
    case costaRica = 321
    case cuba = 323
    case dominica = 325
    case dominicanRepublic = 327
    case franceGuadeloupe = 329
    case grenada = 330
    case denmarkGreenland = 331
    case guatemala = 332
    case honduras = 334
    case haiti = 336
    case unitedStates338 = 338
    case jamaica = 339
    case saintKittsAndNevis = 341
    case saintLucia = 343
    case mexico = 345
    case franceMartinique = 347
    case unitedKingdomMontserrat = 348
    case nicaragua = 350
    case panama351 = 351
    case panama352 = 352
    case panama353 = 353
    case panama354 = 354
    case panama355 = 355
    case panama356 = 356
    case panama357 = 357
    case unitedStatesPuertoRico = 358
    case elSalvador = 359
    case franceSaintPierreAndMiquelon = 361
    case trinidadAndTobago = 362
    case unitedKingdomTurksAndCaicosIslands = 364
    case unitedStates366 = 366
    case unitedStates367 = 367
    case unitedStates368 = 368
    case unitedStates369 = 369
    case panama370 = 370
    case panama371 = 371
    case panama372 = 372
    case panama373 = 373
    case panama374 = 374
    case saintVincentAndTheGrenadines375 = 375
    case saintVincentAndTheGrenadines376 = 376
    case saintVincentAndTheGrenadines377 = 377
    case unitedKingdomBritishVirginIslands = 378
    case unitedStatesUnitedStatesVirginIslands = 379
    case afghanistan = 401
    case saudiArabia = 403
    case bangladesh = 405
    case bahrain = 408
    case bhutan = 410
    case china412 = 412
    case china413 = 413
    case china414 = 414
    case chinaTaiwan = 416
    case sriLanka = 417
    case india = 419
    case iran = 422
    case azerbaijan = 423
    case iraq = 425
    case israel = 428
    case japan431 = 431
    case japan432 = 432
    case turkmenistan = 434
    case kazakhstan = 436
    case uzbekistan = 437
    case jordan = 438
    case korea440 = 440
    case korea441 = 441
    case stateOfPalestine = 443
    case democraticPeoplesRepublicOfKorea = 445
    case kuwait = 447
    case lebanon = 450
    case kyrgyzRepublic = 451
    case chinaMacao = 453
    case maldives = 455
    case mongolia = 457
    case nepal = 459
    case oman = 461
    case pakistan = 463
    case qatar = 466
    case syrianArabRepublic = 468
    case unitedArabEmirates470 = 470
    case unitedArabEmirates471 = 471
    case tajikistan = 472
    case yemen473 = 473
    case yemen475 = 475
    case chinaHongKong = 477
    case bosniaAndHerzegovina = 478
    case franceAdelieLand = 501
    case australia = 503
    case myanmar = 506
    case bruneiDarussalam = 508
    case micronesia = 510
    case palau = 511
    case newZealand = 512
    case cambodia514 = 514
    case cambodia515 = 515
    case australiaChristmasIsland = 516
    case newZealandCookIslands = 518
    case fiji = 520
    case australiaCocosIslands = 523
    case indonesia = 525
    case kiribati = 529
    case laoPeoplesDemocraticRepublic = 531
    case malaysia = 533
    case unitedStatesNorthernMarianaIslands = 536
    case marshallIslands = 538
    case franceNewCaledonia = 540
    case newZealandNiue = 542
    case nauru = 544
    case franceFrenchPolynesia = 546
    case philippines = 548
    case timorLeste = 550
    case papuaNewGuinea = 553
    case unitedKingdomPitcairnIsland = 555
    case solomonIslands = 557
    case unitedStatesAmericanSamoa = 559
    case samoa = 561
    case singapore563 = 563
    case singapore564 = 564
    case singapore565 = 565
    case singapore566 = 566
    case thailand = 567
    case tonga = 570
    case tuvalu = 572
    case vietNam = 574
    case vanuatu576 = 576
    case vanuatu577 = 577
    case franceWallisAndFutunaIslands = 578
    case southAfrica = 601
    case angola = 603
    case algeria = 605
    case franceSaintPaulAndAmsterdamIslands = 607
    case unitedKingdomAscensionIsland = 608
    case burundi = 609
    case benin = 610
    case botswana = 611
    case centralAfricanRepublic = 612
    case cameroon = 613
    case congo = 615
    case comoros616 = 616
    case caboVerde = 617
    case franceCrozetArchipelago = 618
    case coteDivoire = 619
    case comoros620 = 620
    case djibouti = 621
    case egypt = 622
    case ethiopia = 624
    case eritrea = 625
    case gaboneseRepublic = 626
    case ghana = 627
    case gambia = 629
    case guineaBissau = 630
    case equatorialGuinea = 631
    case guinea = 632
    case burkinaFaso = 633
    case kenya = 634
    case franceKerguelenIslands = 635
    case liberia636 = 636
    case liberia637 = 637
    case southSudan = 638
    case libya = 642
    case lesotho = 644
    case mauritius = 645
    case madagascar = 647
    case mali = 649
    case mozambique = 650
    case mauritania = 654
    case malawi = 655
    case niger = 656
    case nigeria = 657
    case namibia = 659
    case franceReunion = 660
    case rwanda = 661
    case sudan = 662
    case senegal = 663
    case seychelles = 664
    case unitedKingdomSaintHelena = 665
    case somalia = 666
    case sierraLeone = 667
    case saoTomeAndPrincipe = 668
    case eswatini = 669
    case chad = 670
    case togoleseRepublic = 671
    case tunisia = 672
    case tanzania674 = 674
    case uganda = 675
    case democraticRepublicOfTheCongo = 676
    case tanzania677 = 677
    case zambia = 678
    case zimbabwe = 679
    case argentineRepublic = 701
    case brazil = 710
    case bolivia = 720
    case chile = 725
    case colombia = 730
    case ecuador = 735
    case unitedKingdomFalklandIslands = 740
    case franceGuiana = 745
    case guyana = 750
    case paraguay = 755
    case peru = 760
    case suriname = 765
    case uruguay = 770
    case venezuela = 775

    /// The country or territory allocated to this MID.
    var description: String {
        switch self {
        case .international:
            return "International (ITU)"
        case .albania:
            return "Albania (Republic of)"
        case .andorra:
            return "Andorra (Principality of)"
        case .austria:
            return "Austria"
        case .portugalAzores:
            return "Portugal - Azores"
        case .belgium:
            return "Belgium"
        case .belarus:
            return "Belarus (Republic of)"
        case .bulgaria:
            return "Bulgaria (Republic of)"
        case .vaticanCityState:
            return "Vatican City State"
        case .cyprus209, .cyprus210, .cyprus212:
            return "Cyprus (Republic of)"
        case .germany211, .germany218:
            return "Germany (Federal Republic of)"
        case .georgia:
            return "Georgia"
        case .moldova:
            return "Moldova (Republic of)"
        case .malta215, .malta229, .malta248, .malta249, .malta256:
            return "Malta"
        case .armenia:
            return "Armenia (Republic of)"
        case .denmark219, .denmark220:
            return "Denmark"
        case .spain224, .spain225:
            return "Spain"
        case .france226, .france227, .france228:
            return "France"
        case .finland:
            return "Finland"
        case .denmarkFaroeIslands:
            return "Denmark - Faroe Islands"
        case .unitedKingdom232, .unitedKingdom233, .unitedKingdom234, .unitedKingdom235:
            return "United Kingdom of Great Britain and Northern Ireland"
        case .unitedKingdomGibraltar:
            return "United Kingdom of Great Britain and Northern Ireland - Gibraltar"
        case .greece237, .greece239, .greece240, .greece241:
            return "Greece"
        case .croatia:
            return "Croatia (Republic of)"
        case .morocco:
            return "Morocco (Kingdom of)"
        case .hungary:
            return "Hungary"
        case .netherlands244, .netherlands245, .netherlands246:
            return "Netherlands (Kingdom of the)"
        case .italy:
            return "Italy"
        case .ireland:
            return "Ireland"
        case .iceland:
            return "Iceland"
        case .liechtenstein:
            return "Liechtenstein (Principality of)"
        case .luxembourg:
            return "Luxembourg"
        case .monaco:
            return "Monaco (Principality of)"
        case .portugalMadeira:
            return "Portugal - Madeira"
        case .norway257, .norway258, .norway259:
            return "Norway"
        case .poland:
            return "Poland (Republic of)"
        case .montenegro:
            return "Montenegro"
        case .portugal:
            return "Portugal"
        case .romania:
            return "Romania"
        case .sweden265, .sweden266:
            return "Sweden"
        case .slovakRepublic:
            return "Slovak Republic"
        case .sanMarino:
            return "San Marino (Republic of)"
        case .switzerland:
            return "Switzerland (Confederation of)"
        case .czechRepublic:
            return "Czech Republic"
        case .republicOfTurkiye:
            return "Republic of Turkiye"
        case .ukraine:
            return "Ukraine"
        case .russianFederation:
            return "Russian Federation"
        case .northMacedonia:
            return "North Macedonia (Republic of)"
        case .latvia:
            return "Latvia (Republic of)"
        case .estonia:
            return "Estonia (Republic of)"
        case .lithuania:
            return "Lithuania (Republic of)"
        case .slovenia:
            return "Slovenia (Republic of)"
        case .serbia:
            return "Serbia (Republic of)"
        case .unitedKingdomAnguilla:
            return "United Kingdom of Great Britain and Northern Ireland - Anguilla"
        case .unitedStatesAlaska:
            return "United States of America - Alaska (State of)"
        case .antiguaAndBarbuda304, .antiguaAndBarbuda305:
            return "Antigua and Barbuda"
        case .netherlandsBonaireSintEustatiusAndSabaCuracaoSintMaarten:
            return "Netherlands (Kingdom of the) - Bonaire, Sint Eustatius and Saba / Curacao / Sint Maarten (Dutch part)"
        case .netherlandsAruba:
            return "Netherlands (Kingdom of the) - Aruba"
        case .bahamas308, .bahamas309, .bahamas311:
            return "Bahamas (Commonwealth of the)"
        case .unitedKingdomBermuda:
            return "United Kingdom of Great Britain and Northern Ireland - Bermuda"
        case .belize:
            return "Belize"
        case .barbados:
            return "Barbados"
        case .canada:
            return "Canada"
        case .unitedKingdomCaymanIslands:
            return "United Kingdom of Great Britain and Northern Ireland - Cayman Islands"
        case .costaRica:
            return "Costa Rica"
        case .cuba:
            return "Cuba"
        case .dominica:
            return "Dominica (Commonwealth of)"
        case .dominicanRepublic:
            return "Dominican Republic"
        case .franceGuadeloupe:
            return "France - Guadeloupe (French Department of)"
        case .grenada:
            return "Grenada"
        case .denmarkGreenland:
            return "Denmark - Greenland"
        case .guatemala:
            return "Guatemala (Republic of)"
        case .honduras:
            return "Honduras (Republic of)"
        case .haiti:
            return "Haiti (Republic of)"
        case .unitedStates338, .unitedStates366, .unitedStates367, .unitedStates368, .unitedStates369:
            return "United States of America"
        case .jamaica:
            return "Jamaica"
        case .saintKittsAndNevis:
            return "Saint Kitts and Nevis (Federation of)"
        case .saintLucia:
            return "Saint Lucia"
        case .mexico:
            return "Mexico"
        case .franceMartinique:
            return "France - Martinique (French Department of)"
        case .unitedKingdomMontserrat:
            return "United Kingdom of Great Britain and Northern Ireland - Montserrat"
        case .nicaragua:
            return "Nicaragua"
        case .panama351, .panama352, .panama353, .panama354, .panama355, .panama356, .panama357, .panama370, .panama371, .panama372, .panama373, .panama374:
            return "Panama (Republic of)"
        case .unitedStatesPuertoRico:
            return "United States of America - Puerto Rico"
        case .elSalvador:
            return "El Salvador (Republic of)"
        case .franceSaintPierreAndMiquelon:
            return "France - Saint Pierre and Miquelon (Territorial Collectivity of)"
        case .trinidadAndTobago:
            return "Trinidad and Tobago"
        case .unitedKingdomTurksAndCaicosIslands:
            return "United Kingdom of Great Britain and Northern Ireland - Turks and Caicos Islands"
        case .saintVincentAndTheGrenadines375, .saintVincentAndTheGrenadines376, .saintVincentAndTheGrenadines377:
            return "Saint Vincent and the Grenadines"
        case .unitedKingdomBritishVirginIslands:
            return "United Kingdom of Great Britain and Northern Ireland - British Virgin Islands"
        case .unitedStatesUnitedStatesVirginIslands:
            return "United States of America - United States Virgin Islands"
        case .afghanistan:
            return "Afghanistan"
        case .saudiArabia:
            return "Saudi Arabia (Kingdom of)"
        case .bangladesh:
            return "Bangladesh (People's Republic of)"
        case .bahrain:
            return "Bahrain (Kingdom of)"
        case .bhutan:
            return "Bhutan (Kingdom of)"
        case .china412, .china413, .china414:
            return "China (People's Republic of)"
        case .chinaTaiwan:
            return "China (People's Republic of) - Taiwan (Province of China)"
        case .sriLanka:
            return "Sri Lanka (Democratic Socialist Republic of)"
        case .india:
            return "India (Republic of)"
        case .iran:
            return "Iran (Islamic Republic of)"
        case .azerbaijan:
            return "Azerbaijan (Republic of)"
        case .iraq:
            return "Iraq (Republic of)"
        case .israel:
            return "Israel (State of)"
        case .japan431, .japan432:
            return "Japan"
        case .turkmenistan:
            return "Turkmenistan"
        case .kazakhstan:
            return "Kazakhstan (Republic of)"
        case .uzbekistan:
            return "Uzbekistan (Republic of)"
        case .jordan:
            return "Jordan (Hashemite Kingdom of)"
        case .korea440, .korea441:
            return "Korea (Republic of)"
        case .stateOfPalestine:
            return "State of Palestine (In accordance with Resolution 99 Rev. Dubai, 2018)"
        case .democraticPeoplesRepublicOfKorea:
            return "Democratic People's Republic of Korea"
        case .kuwait:
            return "Kuwait (State of)"
        case .lebanon:
            return "Lebanon"
        case .kyrgyzRepublic:
            return "Kyrgyz Republic"
        case .chinaMacao:
            return "China (People's Republic of) - Macao (Special Administrative Region of China)"
        case .maldives:
            return "Maldives (Republic of)"
        case .mongolia:
            return "Mongolia"
        case .nepal:
            return "Nepal (Federal Democratic Republic of)"
        case .oman:
            return "Oman (Sultanate of)"
        case .pakistan:
            return "Pakistan (Islamic Republic of)"
        case .qatar:
            return "Qatar (State of)"
        case .syrianArabRepublic:
            return "Syrian Arab Republic"
        case .unitedArabEmirates470, .unitedArabEmirates471:
            return "United Arab Emirates"
        case .tajikistan:
            return "Tajikistan (Republic of)"
        case .yemen473, .yemen475:
            return "Yemen (Republic of)"
        case .chinaHongKong:
            return "China (People's Republic of) - Hong Kong (Special Administrative Region of China)"
        case .bosniaAndHerzegovina:
            return "Bosnia and Herzegovina"
        case .franceAdelieLand:
            return "France - Adelie Land"
        case .australia:
            return "Australia"
        case .myanmar:
            return "Myanmar (Union of)"
        case .bruneiDarussalam:
            return "Brunei Darussalam"
        case .micronesia:
            return "Micronesia (Federated States of)"
        case .palau:
            return "Palau (Republic of)"
        case .newZealand:
            return "New Zealand"
        case .cambodia514, .cambodia515:
            return "Cambodia (Kingdom of)"
        case .australiaChristmasIsland:
            return "Australia - Christmas Island (Indian Ocean)"
        case .newZealandCookIslands:
            return "New Zealand - Cook Islands"
        case .fiji:
            return "Fiji (Republic of)"
        case .australiaCocosIslands:
            return "Australia - Cocos (Keeling) Islands"
        case .indonesia:
            return "Indonesia (Republic of)"
        case .kiribati:
            return "Kiribati (Republic of)"
        case .laoPeoplesDemocraticRepublic:
            return "Lao People's Democratic Republic"
        case .malaysia:
            return "Malaysia"
        case .unitedStatesNorthernMarianaIslands:
            return "United States of America - Northern Mariana Islands (Commonwealth of the)"
        case .marshallIslands:
            return "Marshall Islands (Republic of the)"
        case .franceNewCaledonia:
            return "France - New Caledonia"
        case .newZealandNiue:
            return "New Zealand - Niue"
        case .nauru:
            return "Nauru (Republic of)"
        case .franceFrenchPolynesia:
            return "France - French Polynesia"
        case .philippines:
            return "Philippines (Republic of the)"
        case .timorLeste:
            return "Timor-Leste (Democratic Republic of)"
        case .papuaNewGuinea:
            return "Papua New Guinea"
        case .unitedKingdomPitcairnIsland:
            return "United Kingdom of Great Britain and Northern Ireland - Pitcairn Island"
        case .solomonIslands:
            return "Solomon Islands"
        case .unitedStatesAmericanSamoa:
            return "United States of America - American Samoa"
        case .samoa:
            return "Samoa (Independent State of)"
        case .singapore563, .singapore564, .singapore565, .singapore566:
            return "Singapore (Republic of)"
        case .thailand:
            return "Thailand"
        case .tonga:
            return "Tonga (Kingdom of)"
        case .tuvalu:
            return "Tuvalu"
        case .vietNam:
            return "Viet Nam (Socialist Republic of)"
        case .vanuatu576, .vanuatu577:
            return "Vanuatu (Republic of)"
        case .franceWallisAndFutunaIslands:
            return "France - Wallis and Futuna Islands"
        case .southAfrica:
            return "South Africa (Republic of)"
        case .angola:
            return "Angola (Republic of)"
        case .algeria:
            return "Algeria (People's Democratic Republic of)"
        case .franceSaintPaulAndAmsterdamIslands:
            return "France - Saint Paul and Amsterdam Islands"
        case .unitedKingdomAscensionIsland:
            return "United Kingdom of Great Britain and Northern Ireland - Ascension Island"
        case .burundi:
            return "Burundi (Republic of)"
        case .benin:
            return "Benin (Republic of)"
        case .botswana:
            return "Botswana (Republic of)"
        case .centralAfricanRepublic:
            return "Central African Republic"
        case .cameroon:
            return "Cameroon (Republic of)"
        case .congo:
            return "Congo (Republic of the)"
        case .comoros616, .comoros620:
            return "Comoros (Union of the)"
        case .caboVerde:
            return "Cabo Verde (Republic of)"
        case .franceCrozetArchipelago:
            return "France - Crozet Archipelago"
        case .coteDivoire:
            return "Cote d'Ivoire (Republic of)"
        case .djibouti:
            return "Djibouti (Republic of)"
        case .egypt:
            return "Egypt (Arab Republic of)"
        case .ethiopia:
            return "Ethiopia (Federal Democratic Republic of)"
        case .eritrea:
            return "Eritrea"
        case .gaboneseRepublic:
            return "Gabonese Republic"
        case .ghana:
            return "Ghana"
        case .gambia:
            return "Gambia (Republic of the)"
        case .guineaBissau:
            return "Guinea-Bissau (Republic of)"
        case .equatorialGuinea:
            return "Equatorial Guinea (Republic of)"
        case .guinea:
            return "Guinea (Republic of)"
        case .burkinaFaso:
            return "Burkina Faso"
        case .kenya:
            return "Kenya (Republic of)"
        case .franceKerguelenIslands:
            return "France - Kerguelen Islands"
        case .liberia636, .liberia637:
            return "Liberia (Republic of)"
        case .southSudan:
            return "South Sudan (Republic of)"
        case .libya:
            return "Libya (State of)"
        case .lesotho:
            return "Lesotho (Kingdom of)"
        case .mauritius:
            return "Mauritius (Republic of)"
        case .madagascar:
            return "Madagascar (Republic of)"
        case .mali:
            return "Mali (Republic of)"
        case .mozambique:
            return "Mozambique (Republic of)"
        case .mauritania:
            return "Mauritania (Islamic Republic of)"
        case .malawi:
            return "Malawi"
        case .niger:
            return "Niger (Republic of the)"
        case .nigeria:
            return "Nigeria (Federal Republic of)"
        case .namibia:
            return "Namibia (Republic of)"
        case .franceReunion:
            return "France - Reunion (French Department of)"
        case .rwanda:
            return "Rwanda (Republic of)"
        case .sudan:
            return "Sudan (Republic of the)"
        case .senegal:
            return "Senegal (Republic of)"
        case .seychelles:
            return "Seychelles (Republic of)"
        case .unitedKingdomSaintHelena:
            return "United Kingdom of Great Britain and Northern Ireland - Saint Helena"
        case .somalia:
            return "Somalia (Federal Republic of)"
        case .sierraLeone:
            return "Sierra Leone"
        case .saoTomeAndPrincipe:
            return "Sao Tome and Principe (Democratic Republic of)"
        case .eswatini:
            return "Eswatini (Kingdom of)"
        case .chad:
            return "Chad (Republic of)"
        case .togoleseRepublic:
            return "Togolese Republic"
        case .tunisia:
            return "Tunisia"
        case .tanzania674, .tanzania677:
            return "Tanzania (United Republic of)"
        case .uganda:
            return "Uganda (Republic of)"
        case .democraticRepublicOfTheCongo:
            return "Democratic Republic of the Congo"
        case .zambia:
            return "Zambia (Republic of)"
        case .zimbabwe:
            return "Zimbabwe (Republic of)"
        case .argentineRepublic:
            return "Argentine Republic"
        case .brazil:
            return "Brazil (Federative Republic of)"
        case .bolivia:
            return "Bolivia (Plurinational State of)"
        case .chile:
            return "Chile"
        case .colombia:
            return "Colombia (Republic of)"
        case .ecuador:
            return "Ecuador"
        case .unitedKingdomFalklandIslands:
            return "United Kingdom of Great Britain and Northern Ireland - Falkland Islands (Malvinas)"
        case .franceGuiana:
            return "France - Guiana (French Department of)"
        case .guyana:
            return "Guyana"
        case .paraguay:
            return "Paraguay (Republic of)"
        case .peru:
            return "Peru"
        case .suriname:
            return "Suriname (Republic of)"
        case .uruguay:
            return "Uruguay (Eastern Republic of)"
        case .venezuela:
            return "Venezuela (Bolivarian Republic of)"
        }
    }
}

