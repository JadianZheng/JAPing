# JAPing

[![CI Status](https://img.shields.io/travis/JadianZheng/JAPing.svg?style=flat)](https://travis-ci.org/JadianZheng/JAPing)
[![Version](https://img.shields.io/cocoapods/v/JAPing.svg?style=flat)](https://cocoapods.org/pods/JAPing)
[![License](https://img.shields.io/cocoapods/l/JAPing.svg?style=flat)](https://cocoapods.org/pods/JAPing)
[![Platform](https://img.shields.io/cocoapods/p/JAPing.svg?style=flat)](https://cocoapods.org/pods/JAPing)

## Example

### Code
``` Swift
let baiduPinger = JAPing(hostName: "baidu.com", unexpertError: nil)
baiduPinger.configuare.pingCount = 8
baiduPinger.start()
```
### Result - See more in example
```
PING baidu.com (220.181.57.216)
64 bytes from 220.181.57.216: icmp_seq=0 time=0.049 ms
64 bytes from 220.181.57.216: icmp_seq=1 time=0.05 ms
64 bytes from 220.181.57.216: icmp_seq=2 time=0.048 ms
64 bytes from 220.181.57.216: icmp_seq=3 time=0.048 ms
64 bytes from 220.181.57.216: icmp_seq=4 time=0.049 ms
64 bytes from 220.181.57.216: icmp_seq=5 time=0.055 ms
64 bytes from 220.181.57.216: icmp_seq=6 time=0.048 ms
64 bytes from 220.181.57.216: icmp_seq=7 time=0.055 ms
--- baidu.com ping statistics ---
8 packets transmitted, 8 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.048/0.05/0.055/0.003 ms
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JAPing is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JAPing'
```

## Author

JadianZheng, jadianzheng@gmail.com

## License

JAPing is available under the MIT license. See the LICENSE file for more info.
