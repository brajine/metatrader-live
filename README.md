# [Metatrader.live](https://metatrader.live)

<p align="center">
  <span>English</span> |
  <a href="/lang/README_ru.md">Pусский</a>
</p>

Trade data publishing from the Metatrader terminal to the WEB (REST API, WebSockets, HTML available). MQL5 client module (Expert Advisor) for metatrader.live service.

- [Introduction](/README.md#introduction)
- [Usage](/README.md#usage)
- [Data safety](/README.md#data-safety)
- [Data transfer and network load](/README.md#data-transfer-and-network-load)
- [System requirements](/README.md#system-requirements)
- [Limitations](/README.md#limitations)
- [Installation](/README.md#installation)
- [Swagger API](/README.md#swagger-api)
- [License](/README.md#license)

## Introduction
`Metatrader` is one of the most common tools for accessing the `Forex` market. The built-in programming language `MQL5` designed to implement complex automated trading strategies, and is one of the reasons for the high popularity of the `Metatrader` terminal. However, today more and more traders need not only market access, but also a reliable way of data delivering to the `Web`. Unfortunately, the `Metatrader` terminal provides only basic internet access functions.

This project provides a simple and reliable way of delivering data from the Metatrader terminal to the Internet. Data updates is performed every minute or every second - at your choice. The data transmitted by the terminal is immediately available `online` - no registration is required. Data is provided in several ways:
1. WEB-page `metatrader.live/accounts/{Page name}`
2. REST API `metatrader.live/api/rest/{Page name}`
3. WebSockets API `metatrader.live/api/wss/{Page name}`

## Usage
Expert Advisor (`MTLive.mq5`) from this repository can be used to remotely control the operation of trading robots, to monitor the state of `Metatrader` terminal, or to transfer data to other services and systems.

```cpp
#include "MTLive.mqh"

void OnInit() {
   MTLive::Init(Ip, Port);
}

void OnTimer() {
   MTLive::Update();
}

void OnDeinit(const int reason) {
   MTLive::DeInit();
}
```

In addition, the transport module (`MTTransport.mqh`) can be used independently and it can be easily integrated into any other system for efficient data transfer from the Metatrader terminal to the Web through this service.

## Data safety
The project was originally designed to be as safe as possible. You decide which account data will be transferred - or not transferred at all. Publishing only trade data (without account one) makes your data anonymized.

In addition, this project is fully open sourced and does not contain hidden threats or malwares.

## Data transfer and network load
The second goal of the project is speed. No, SPEED! Extremely efficient binary protocol is used for data delivery, which reduces the network load tenfold compared to other transfer methods (XML, JSON). With 30 opened orders, per-second update rate and high market volatility, data transfer does not exceed 1 MB per hour. A few open positions in a flat market generate less than 100KB of data transfer per hour.

Compare this with the `yahoo.com` homepage (3.7MB).

## System requirements
Only `Metatrader 5 (MQL5)` terminal is currently supported. Version for `Metatrader 4` is under development.

## Limitations
This version limits the number of simulteneously opened orders by 30. This limitation may be changed in the future.

## Installation
Download the Expert Advisor files from the `/src` directory or use the `git clone` tools. Source files should be placed in the Metatrader working folder: `{MetaTrader Data Folder}/MQL5/Experts/Advisors`.

![Metatrader Data Folder](/img/data-folder.png "Metatrader Data Folder")

It is also necessary to add `metatrader.live` to the allowed servers list:

![Metatrader Allow WebRequest](/img/allow-web-request.png "Metatrader Allow WebRequest")

After that, compile and attach the `MTLive` Expert Advisor to any chart, specify `Page name` alias and refresh rate.

![EA Input parameters](/img/input-parameters.png "EA Input parameters")

The Expert Advisor displays working messages in the `Experts` tab.
If everything was done correctly, the data is already online. Point your Internet browser to `metatrader.live/accounts/{Page name}`.

## Swagger API
API data format (REST API) is available: [metatrager.live/api/swagger](https://metatrader.live/api/swagger)

## License
The content of this project itself and the underlying source code are licensed under the [MIT license](/LICENSE).