import git
import argparse

def squash_saved_commits(repo_path, new_title, force_push=False, commit_keyword="保存"):
    """
    自动压缩当前分支末尾连续包含关键字(默认"保存")的提交为一个新提交
    
    :param repo_path: Git仓库的路径
    :param new_title: 新提交的标题
    :param force_push: 是否强制推送
    :param commit_keyword: 需要匹配的提交关键字
    """
    repo = git.Repo(repo_path)
    
    # 检查工作区状态
    if repo.is_dirty():
        raise Exception("存在未提交的修改，请先提交或暂存更改")

    # 查找连续的符合要求的提交
    n = 0
    for commit in repo.iter_commits():
        if commit_keyword not in commit.message:
            break
        n += 1
    
    if n == 0:
        raise ValueError(f"未找到包含关键字 '{commit_keyword}' 的提交")

    print(f"🔍 发现最近 {n} 个包含 '{commit_keyword}' 的连续提交")

    try:
        # 提取原始提交信息（从旧到新排序）
        commits = list(repo.iter_commits(max_count=n))
        messages = [commit.message.strip() for commit in reversed(commits)]
        details = "\n".join([f"* {msg}" for msg in messages])
        new_message = f"{new_title}\n\n合并的保存记录：\n{details}"

        # 执行压缩操作
        repo.git.reset("--soft", f"HEAD~{n}")
        repo.git.commit("-m", new_message)
        print(f"✅ 已合并 {n} 个提交：{new_title}")

        # 强制推送
        if force_push:
            current_branch = repo.active_branch.name
            repo.git.push("origin", current_branch, "--force")
            print(f"🚀 已强制推送至远程分支 '{current_branch}'")

    except git.GitCommandError as e:
        print(f"❌ 操作失败：{str(e)}")
        # 错误时恢复HEAD到原始位置
        repo.git.reset("--hard", "ORIG_HEAD")
        print("🔙 已恢复原始提交状态")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="自动压缩当前分支末尾连续包含关键字的提交为一个新提交",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument(
        "-m", "--message",
        required=True,
        help="新提交的标题 (必填)"
    )
    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="强制推送到远程仓库 (默认关闭)"
    )
    parser.add_argument(
        "-k", "--keyword",
        default="保存",
        help="需要匹配的提交关键字 (默认值: 保存)"
    )
    parser.add_argument(
        "--repo-path",
        default=".",
        help="Git仓库路径 (默认当前目录)"
    )
    args = parser.parse_args()
    try:
        squash_saved_commits(
            repo_path=args.repo_path,
            new_title=args.message,
            force_push=args.force,
            commit_keyword=args.keyword
        )
    except Exception as e:
        print(f"❌ 发生错误: {str(e)}")
        exit(1)