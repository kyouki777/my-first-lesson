using UnityEngine;

[ExecuteAlways]
public class Note : MonoBehaviour
{
    [TextArea(3, 20)]
    public string note = "Write your notes here...";
}
