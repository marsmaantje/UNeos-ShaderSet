using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderFloat4Animator : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]
    private Material shader;

    [SerializeField]
    private string propertyName;

    [SerializeField]
    private Vector4 speed;

    [SerializeField]
    private Vector4 Offset;

    // Update is called once per frame
    void Update()
    {
        Vector4 val = speed * Time.time + Offset;
        shader.SetVector(propertyName, val);
    }
}
