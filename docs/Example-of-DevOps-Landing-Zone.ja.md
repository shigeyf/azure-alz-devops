# プロビジョニングされた DevOps リソースの例

[English](./Example-of-DevOps-Landing-Zone.md) | [日本語](./Example-of-DevOps-Landing-Zone.ja.md)

このドキュメントでは、このプロジェクトのリポジトリによってプロビジョニングされたリソースの例を示します。

## プロビジョニングされたリソースグループ

この例では、以下のリソースグループが生成されています。

- [Bootstrap リソース](#provisioned-bootstrap-resources): `rg-alz-devops-bootstrap-jpe-yxci`
- [Identity リソース](#provisioned-identity-resources): `rg-alz-devops-identity-jpe-068e`
- [Agent リソース](#provisioned-agents-resources): `rg-alz-devops-agents-jpe-068e`
- [Network リソース](#provisioned-network-resources): `rg-alz-devops-network-jpe-068e`

![リソースグループ](/docs/images/provisioned-resources-example-1-rg.png)

<a id="provisioned-bootstrap-resources"></a>

## プロビジョニングされた "Bootstrap" リソース

このリソースグループには以下が含まれます。

- **Key Vault**: カスタマーマネージドキー (CMK) と GitHub PAT などのシークレットを保存します
- **Storage (Blob)**: 以下のファイルを保存します
  - Terraform 状態ファイル
    - DevOps ランディングゾーンのリソース展開の Terraform 状態管理ファイル
    - プロジェクトごとのリソース展開の Terraform 状態管理ファイル
  - プロジェクトごとの CI/CD ログデータ

![ブートストラップ リソース](/docs/images/provisioned-resources-example-2-bootstrap.png)

<a id="provisioned-identity-resources"></a>

## プロビジョニングされた "Identity" リソース

このリソース グループには、7 つの **ユーザー割り当てマネージド ID** が含まれています。

1. **機能開発用の環境** 向けの Azure サブスクリプション (開発者向け) に対する Terraform CI (`plan`) 操作のためのユーザー割り当てマネージド ID
1. **開発環境** 向けの Azure サブスクリプションに対する Terraform CI (`plan`) 操作のためのユーザー割り当てマネージド ID
1. **開発環境** 向けのAzure サブスクリプションに対する Terraform CI/CD (`apply`) 操作のためのユーザー割り当てマネージド ID
1. **ステージング環境** 向けの Azure サブスクリプションに対する Terraform CI (`plan`) 操作のためのユーザー割り当てマネージド ID
1. **ステージング環境** 向けの Azure サブスクリプションに対する Terraform CI/CD (`apply`) 操作のためのユーザー割り当てマネージド ID
1. **本番環境** 向けの Azure サブスクリプションに対する Terraform CI (`plan`) の操作のためのユーザー割り当てマネージド ID
1. **本番環境** 向け のAzure サブスクリプション環境に対する Terraform CI/CD の ID (`apply`) 操作のためのユーザー割り当てマネージド ID

![DevOps ランディング ゾーンの ID リソース](/docs/images/provisioned-resources-example-3-devops-identity.png)

<a id="provisioned-agents-resources"></a>

## プロビジョニングされた "Agents" リソース

このリソース グループには、以下のリソースが含まれています。

- **Container Registry (ACR)**: GitHub Runner のコンテナ イメージを管理します
- **Container App (ACA) 環境**
- **Log Analytics ワークスペース**: コンテナ アプリケーションのログを管理します
- **ユーザー割り当てマネージド ID**: シークレット データ アクセス (Key Vault に保存) と Container Registry (ACR) からのコンテナ イメージのプルに使用する ID を管理します

> [!NOTE]
> Container App Environment リソースは、ACA と ACI の両方を複数のプロジェクトで共通リソースとして使用する場合に生成されます。このリソース自体にはコストは発生しません。

Container App (ACA) を使用する場合:

- **コンテナアプリ (ACA) ジョブ**: セルフホステッド GitHub Runner をホストするイベントトリガージョブ

Container Instance (ACI) を使用する場合:

- 複数の **コンテナインスタンス (ACI)**: セルフホステッド GitHub Runner をホストする複数のインスタンス

![DevOps ランディングゾーン エージェント リソース ACA)](/docs/images/provisioned-resources-example-4-devops-agents1.png)

![DevOps ランディングゾーン エージェント リソース (ACI)](/docs/images/provisioned-resources-example-6-devops-agents3.png)

DevOps ランディングゾーンでプライベートネットワークを有効にすると、コンテナアプリ環境用に自動生成されたネットワークリソースを含む追加のリソースグループが表示されます。

![DevOps ランディングゾーン エージェント リソース (CAE)](/docs/images/provisioned-resources-example-5-devops-agents2.png)

<a id="provisioned-network-resources"></a>

## プロビジョニングされた "Network" リソース

このリソース グループには以下が含まれます。

- **仮想ネットワーク** と以下のサブネット
  - プライベート エンドポイント リソース用のサブネット (`snet-private-endpoints`)
  - ゲートウェイ用のサブネット (`GatewaySubnet`): ネットワーク トラフィックの出力は NAT ゲートウェイを経由します
  - コンテナ アプリ環境用のサブネット (`snet-container-apps`)
  - コンテナ インスタンス用のサブネット (`snet-container-instances`)
- 各サブネットの**ネットワーク セキュリティ グループ** (ただし、ゲートウェイ サブネットを除く)
- **NAT ゲートウェイ**
  - 上記の **仮想ネットワーク** のゲートウェイ用サブネットに紐づけされます
- **パブリック IP アドレス**: NAT ゲートウェイ経由の送信トラフィックに使用します
- **プライベート エンドポイント**
  - Blob Storage 用
  - Key Vault 用
  - Container Registry 用
- **プライベートDNSゾーン**: 上記の仮想ネットワークに関連付けられています
  - Blob Storage 用
  - Key Vault 用
  - Container Registry 用

![DevOpsランディングゾーンのネットワークリソース](/docs/images/provisioned-resources-example-7-devops-network.png)
