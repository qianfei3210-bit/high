cd "D:\work\database\STATA\high"
use City2.dta, clear

mata:
// 读取经纬度
lon = st_data(., "X")
lat = st_data(., "Y")
n = rows(lon)
K = 4                // 设置邻居数

// 初始化距离矩阵
D = J(n,n,0)
for(i=1; i<=n; i++){
    for(j=1; j<=n; j++){
        D[i,j] = sqrt( (lon[i]-lon[j])^2 + (lat[i]-lat[j])^2 )
    }
}

// 初始化 KNN 矩阵
W = J(n,n,0)
for(i=1; i<=n; i++){
    row = D[i,.]
    idx = order(row', 1)           // 从小到大排序
    nn = idx[2..(K+1)]             // 最近 K 个邻居（排除自身）
    for(j=1; j<=K; j++){
        W[i, nn[j]] = 1
    }
}

// 行标准化
row_sums = rowsum(W)
W_std = W :/ row_sums

// 输出为 Stata 矩阵
st_matrix("Wk", W_std)
end


* 5. 创建 spmatrix 对象
spmatrix import matrix W_spatial = W_knn_matrix
spmatrix dir

* 6. 可选：保存矩阵到 .dta 文件
save W_knn.dta, replace