# GKI 6.1 网络优化补丁工具

本目录仅包含向 Android GKI 6.1 内核追加“网络优化配置”的脚本，不包含任何 KernelSU/SUSFS/KPM 等内容。

## 功能
- 向 `common/arch/arm64/configs/gki_defconfig` 追加以下配置：
  - Netfilter/IPSet 全家桶（含 xt_set 支持）
  - 常用 iptables 扩展（TPROXY/REDIRECT/MARK/ADDRTYPE/MULTIPORT/OWNER/SOCKET 等）
  - IPv6 NAT（NPT/MASQUERADE 等）
  - BBR 拥塞控制 + FQ 调度

## 使用方法
1. 准备 GKI 源码（例如 `android14-6.1-xxx`）：
   ```bash
   repo init ...
   repo sync ...
   # 此时你的 GKI 根目录应包含 ./common
   ```
2. 执行脚本：
   ```bash
   # 方式 A：在 GKI 根目录执行
   bash /path/to/gki_kernel/net_opt_patch.sh

   # 方式 B：传入 GKI 根目录
   bash /path/to/gki_kernel/net_opt_patch.sh /absolute/path/to/GKI_ROOT
   ```
3. 编译内核（Bazel 或 build.sh），脚本只会“追加配置”，不会修改其他逻辑。

## 注意
- 该脚本是幂等的，但如果多次执行会重复追加相同行。通常在一个构建周期执行一次即可。
- 如果你希望做成 GitHub Actions 的一个步骤，只需在 "进入 $CONFIG" 后调用：
  ```bash
  bash "$GITHUB_WORKSPACE/gki_kernel/net_opt_patch.sh" "$GITHUB_WORKSPACE/$CONFIG"
  ```
- 若需扩展/精简配置，请直接修改 `net_opt_patch.sh` 中的 `echo` 列表。
