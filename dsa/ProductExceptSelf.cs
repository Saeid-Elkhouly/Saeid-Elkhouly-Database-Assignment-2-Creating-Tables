
int[] nums = [1, 2, 3, 4];

int[] result1 = Solution.ProductExceptSelfWithArrays(nums);
Console.WriteLine(string.Join(", ", result1));

int[] result2 = Solution.ProductExceptSelf(nums);
Console.WriteLine(string.Join(", ", result2));

public class Solution
{
    // 5.1
    // Time Complexity: O(n)
    // Space Complexity: O(n)
    public static int[] ProductExceptSelfWithArrays(int[] nums)
    {
        int n = nums.Length;

        int[] prefix = new int[n];
        int[] suffix = new int[n];
        int[] answer = new int[n];

        prefix[0] = 1;

        for (int i = 1; i < n; i++)
        {
            prefix[i] = prefix[i - 1] * nums[i - 1];
        }

        suffix[n - 1] = 1;

        for (int i = n - 2; i >= 0; i--)
        {
            suffix[i] = suffix[i + 1] * nums[i + 1];
        }

        for (int i = 0; i < n; i++)
        {
            answer[i] = prefix[i] * suffix[i];
        }

        return answer;
    }

    // 5.2
    // Time Complexity: O(n)
    // Space Complexity: O(1) extra space (excluding output array)
    public static int[] ProductExceptSelf(int[] nums)
    {
        int n = nums.Length;

        int[] answer = new int[n];

        answer[0] = 1;

        for (int i = 1; i < n; i++)
        {
            answer[i] = answer[i - 1] * nums[i - 1];
        }

        int suffix = 1;

        for (int i = n - 1; i >= 0; i--)
        {
            answer[i] *= suffix;
            suffix *= nums[i];
        }

        return answer;
    }
}
