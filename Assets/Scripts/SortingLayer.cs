using UnityEngine;

public class SpriteSortingOrder : MonoBehaviour
{
    private SpriteRenderer spriteRenderer;

    void Start()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
    }

    void LateUpdate()
    {
        // Lower Y position means "in front", higher means "behind"
        spriteRenderer.sortingOrder = Mathf.RoundToInt(transform.position.y * -100);
    }
}
