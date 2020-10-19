## IAP,Inner App Purchase，内购

### 内购基本流程

- 由运营，或者自己到`iTunes connect`生成能用于购买的商品，到我们开发手上就是一个商品id`productID`
- 基于这个`productID`请求`苹果IAP服务器`，获取这个商品id对应的`SKProduct`商品内容
- 使用`SKPurchaseQueue`加入上面的商品，然后App会调起付费页面
- 付费页面确认输入账号密码之后，`苹果IAP服务器`接到我们发起的请求后，会先告诉我们他正在处理中
- 在处理完成后，`苹果IAP服务器`会给我们发回关于这次交易的`receiptData`
- 从`appStoreReceiptURL`获取交易收据，然后使用服务器、或者本地放起验单流程
- 待验单结果返回成功后，将这次交易关闭，完成交易

![image](http://note.youdao.com/yws/res/644/WEBRESOURCE8bbb868f1e528f2279e3697cb303ad25)

### 项目应用



基本的使用流程


自己的需求
自己实现过程中遇到的问题


比较资料，学习资料看到的问题，这些问题怎么处理，应用于自己的需求能做些什么

还有啥疑问，和未实现