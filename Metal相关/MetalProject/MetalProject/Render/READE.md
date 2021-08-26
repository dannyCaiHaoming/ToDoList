# 渲染



## 渲染的步骤

1.  获取GPU抽象,使用`MTLCreateSystemDefaultDevice()`获取当前设备能够使用Metal的GPU对象
2.  根据`device`构建`MTLLIbrary`,使用`MTLLibrary`构建`顶点着色器函数`和`图元着色器函数`
3. 使用`MTLRenderPipelineState`描述数据传输给GPU之前需要经历的`顶点着色器`和`图元着色器`以及过程中的一些状态,用于描述管道。而这个管道状态由`MTLRenderPipelineDescriptor`构造 
4.  有了管道之后，需要将渲染操作指令传递给GPU执行。需要创建一个命令队列`MTLCommandQueue`。命令队列等于一个列车轨道
5. 有了轨道需要载具，于是创建`MTLCommandBuffer` 命令缓冲区当做一节节车厢
6. 使用`MTLRenderCommandEncoder`为命令缓冲区写入每个命令，`MTLRenderCommandEncoder`需要调用`endEncoding`之后，才能让`MTLCommandBuffer` 命令缓冲区确认结束命令写入，然后开始发送到GPU进行执行。


## 渲染中数据的传输

1. setVertexBytes & setVertexBuffer 区别
```
    介绍里面setVertexBytes等于与创建一个buffer，且将数据扔进buffer里面
    但是区别在于，这个方法避免过度创建buffer来存储数据，而由metal帮忙管理。但是这也有限制，
    小于4kb的数据用setVertexBytes会比较好，大于的话还是用setVertexBuffer。
```



## 渲染中msl语言相关

### msl特殊关键字
- position
- stage_in
- vertex_id

## 渲染中几何问题

### 齐次坐标
将三维坐标改成用四位数来表示，最后一位用于表明是点还是方向。

#### 齐次坐标平移变换
通过`矩阵左乘`

### MVP 矩阵
实际使用，要反过来成P*V*M=MVP矩阵
最终生成frustum四凌锥的可视区域

#### 模型矩阵
物体中心


#### 视图（相机）矩阵
将移山行动变为单纯移动相机即可

#### 投影矩阵
立体效果平面化，一个点是否能在屏幕上画出来，远近的一个点哪个优先。
区分是透视投影，或者是正交投影

- 将立体效果平面化fov（field of view）生成
- 窗口比例
- 最近的平面
- 最远的平面
