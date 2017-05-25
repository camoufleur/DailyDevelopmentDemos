# iOS多层单选标签选择器

先看下效果:

![最终效果](effect.gif)

思路是使用 `UICollectionView` 来写该控件.

***

使用起来有以下几点限制:

- 位置是固定死的, 顶部与导航栏下方对齐;
- 数据中需要有`level`字段, 根为`0`, 第一层(年级)为`1`, 第二层(科目)为`2`, 以此类推;
- `sectionTitle`存在于每一层中, 方便刷新;

个人简书主页: [Camoufleur](http://www.jianshu.com/u/5eb32816c254)