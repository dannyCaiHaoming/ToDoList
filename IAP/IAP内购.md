## IAP,Inner App Purchase，内购

#### 参考

[贝聊IAP的实现](https://juejin.im/post/6844903538254938126#heading-4)</br>
[Leo的博客](https://github.com/LeoMobileDeveloper/Blogs/tree/master/iOS/IAP)</br>
[njuxjy基于以上两个的总结和个人实现](https://juejin.im/post/6844904021229060103#heading-15)



### 内购基本流程

- 由运营，或者自己到`iTunes connect`生成能用于购买的商品(目前用到的是`订阅型商品`)，到我们开发手上就是一个商品id`productID`
- 基于这个`productID`请求`苹果IAP服务器`，获取这个商品id对应的`SKProduct`商品内容
- 使用`SKPurchaseQueue`加入上面的商品，然后App会调起付费页面
- 付费页面确认输入账号密码之后，`苹果IAP服务器`接到我们发起的请求后，会先告诉我们他正在处理中
- 在处理完成后，`苹果IAP服务器`会给我们发回关于这次交易的`receiptData`
- 从`appStoreReceiptURL`获取交易收据，然后使用服务器、或者本地放起验单流程
- 待验单结果返回成功后，将这次交易关闭，完成交易
- 如果购买完成还没等成功的回调即退出的时候，由于在应用初始化的时候即对`PaymentQueue`增加回调，因此内购状态发生变化的时候，仍然会走回调，会对完成的交易进行本地receipt和苹果后台进行校验，等这个单完成校验之后，才会把当次的交易finish掉。如果用户没有重新进来而是卸载，我们提供restore让用户重新找回的方式。

![image](http://note.youdao.com/yws/res/644/WEBRESOURCE8bbb868f1e528f2279e3697cb303ad25)

### 项目应用

- 页面展示商品价格(最新且受所在区域影响)
- 只是`一对一`，且`没有绑定用户`
- 需要在用户购买完成之后，将用户状态升级为`VIP`


### 实现中遇到的问题

- [x] 需要考虑运营方面在App线上运行时修改价格，因此需要每次购买的时候重新获取一次`SKProduct`，然后再使用`SKPurchaseQueue`将此商品添加进去。

```
这里使用了一个状态标志位用于区分只是单纯的刷题商品列表，还是刷新完商品并且发起
```

- [ ] 由于`PurchaseManager`设计成单例，因此使用`block`或者`delegate`的回调方式都只能保证一对一的消息传递
```
目前需求还不需要考虑这种情况，可以设计成用数组持有`代理发起者`，或者通知形式
```

- [ ] `appStoreReceiptURL`获取本地收据数据的时候，有可能会不存在的情况，这时候正常可以发起一个刷新收据的请求`SKReceiptRefreshRequest`，只不过这个请求会弹框让用户重新输入一次账号密码不太友好，所以就没有做，后面的`交易关闭`时机的处理可以不用强求刷新也可以

- [x] `IAP支付机制`与我方业务逻辑方法调用顺序导致的`挂单``掉单`问题
```
线上曾爆发过“付费后无法使用”“重复扣费的问题”
基本原因就是：
（1）网络慢，毕竟每笔交易都要经过太平洋，或者大西洋，导致用户可能kill掉进程，然后这个时候实际扣费成功，但是App端没有做到相应业务逻辑的处理。
目前处理就是：
(1)获取到交易<purchased>的状态之后，先马上给用户身份升级为VIP
(2)在验单结束之后，才把这次的交易finish掉，这样就能保证用户不会重复进行扣费！！！！！
```
- [x] `测试包`和`TestFlight包`内购的时候都是在`沙盒环境`的，只有上线后的包才会是跟`IAP服务器`验证。因此苹果人员审核的时候，我们的app在验单的时候还是走的`沙盒环境`
```
需要对验证步骤修改成:
(1)IAP服务器验证
(2)如果验证得到21007
(3)则需要进行沙盒验证
(4) 1,3成功则完成交易
```

- [ ] `Restore`操作会为之前`finish`的交易重新传递一个新的交易。因此`SKPurchaseQueue`会重新得到n多个交易。
```
貌似是需要对全部交易又调用一次`finish`,
然后在paymentQueueRestoreCompletedTransactionsFinished中处理业务逻辑更新
```


### 思考

- 商品类型<->商品区分<->用户区分

商品类型有如下：</br>

    - 消耗型
    - 非消耗型
    - 自动续期订阅型
    - 非续期订阅型


目前使用到的应该是最简单的情况，`订阅型商品`绑定一台设备，因为也没有设计可登录的用户系统。</br>
但是如果是使用`消耗型商品`并且可能存在同一个`productId`对应不同的`虚拟商品内容`然后还需要区分不同的`用户`。</br>
从参考文章中可以得到，目前苹果的设计及各种奇怪的情况，并不能完全`100%`保证能将以上这种复杂的情况保证完全映射。
```
(1)`SKPayment`进入购买队列的时候，使用交易时间[ts]关联当前虚拟商品，用户id,持久化存储到沙盒，keychain都可
(2)等交易`purchased`回到的时候，在步骤(1)中查找合理范围内的数据，并且把交易订单号也填充进去。
```

- 验单队列

如上复杂情况。如果有多个交易需要发起验单的，就需要对这些请求进行统一管理。`贝聊`文章中就有详细介绍。</br>
主要考虑的是：

    - 触发时机
    - 去重
    - 优先级
    - 重试时间渐增
    

    