class Solution:
    def search(self, nums: List[int], target: int) -> int:
        low = 0
        high = len(nums) - 1
        while low <= high:
            mid = (high + low) // 2
            if nums[mid] == target:
                return mid
            if nums[mid] > target:
                high = mid - 1
            else:
                low = mid + 1
        return -1

nums = [-1,0,3,5,9,12]
target = 0
solution = Solution()
result = solution.search(nums,target)
print(result)
