using UnityEngine;
using UnityEngine.Tilemaps;

public class TilemapSortingOrder : MonoBehaviour
{
    private TilemapRenderer tilemapRenderer;

    void Start()
    {
        tilemapRenderer = GetComponent<TilemapRenderer>();
    }

    void LateUpdate()
    {
        tilemapRenderer.sortingOrder = Mathf.RoundToInt(transform.position.y * -100);
    }
}
