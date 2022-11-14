using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderTextureAnimator : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]
    private Material shader;

    [SerializeField]
    private string propertyName;

    [SerializeField]
    private Vector2 speed;

    [SerializeField]
    private Vector2 Offset;

    // Update is called once per frame
    void Update()
    {
        Vector2 val = speed * Time.time + Offset;
        shader.SetTextureOffset(propertyName, val);
    }
}
