using UnityEngine;
using Pathfinding;

public class TestCaretakerMove : MonoBehaviour
{
    public Transform player;

    void Start()
    {
        AIPath aiPath = GetComponent<AIPath>();
        AIDestinationSetter setter = GetComponent<AIDestinationSetter>();

        setter.target = player;
        aiPath.canMove = true;
        aiPath.maxSpeed = 3.5f;

        Debug.Log("TestCaretakerMove: AIPath should start moving.");
    }
}
