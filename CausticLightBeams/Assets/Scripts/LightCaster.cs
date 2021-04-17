﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// This class is responsible for casting light through specular objects. Script takes the view of the light camera and
/// outputs the visibility details to a render texture
/// </summary>
public class LightCaster : MonoBehaviour
{
    /// <summary>
    /// Shader tag used to help identify specular objects. Specular objects are expected to have this same value in their
    /// respective shaders
    /// </summary>
    private const string SPECULAR_TAG = "SpecularObj";

    /// <summary>
    /// Flag indicating the type of light camera this object should be. False represents a Normal camera, True represents a Position camera
    /// </summary>
    public bool PositionCamera = false;

    /// <summary>
    /// Shader used to help render and store the normals of seen objects
    /// </summary>
    public Shader SpecularNormalRenderShader;

    /// <summary>
    /// Shader used to help render and store the positions of seen objects
    /// </summary>
    public Shader SpecularPosRenderShader;

    /// <summary>
    /// Texture to receive the normals or positions from the specular objects seen by the light camera.
    /// </summary>
    private Texture targetTexture;

    /// <summary>
    /// Camera used as the "Light casting". Any objects seen by the camera are said to be "casted upon" by light.
    /// </summary>
    private Camera lightCamera;

    // Start is called before the first frame update
    void Start()
    {
        lightCamera = GetComponent<Camera>();

        Debug.Assert(lightCamera != null);

        if (this.PositionCamera)
        {
            Debug.Assert(SpecularPosRenderShader != null);
            lightCamera.SetReplacementShader(SpecularPosRenderShader, SPECULAR_TAG);
        }
        else
        {
            Debug.Assert(SpecularNormalRenderShader != null);
            lightCamera.SetReplacementShader(SpecularNormalRenderShader, SPECULAR_TAG);
        }

        targetTexture = lightCamera.targetTexture;
        Debug.Assert(targetTexture != null);
    }

    private void OnPostRender()
    {
        Matrix4x4 bias = new Matrix4x4()
        {
            m00 = 0.5f, m01 = 0,    m02 = 0,    m03 = 0.5f,
            m10 = 0,    m11 = 0.5f, m12 = 0,    m13 = 0.5f,
            m20 = 0,    m21 = 0,    m22 = 0.5f, m23 = 0.5f,
            m30 = 0,    m31 = 0,    m32 = 0,    m33 = 1,
        };

        Matrix4x4 lightMatrix = bias * lightCamera.projectionMatrix * lightCamera.worldToCameraMatrix;

        //Load the appropriate texture's into other shaders globally.
        if (PositionCamera)
        {
            Shader.SetGlobalTexture("_SpecularPosTexture", targetTexture);
        }
        else
        {
            Shader.SetGlobalTexture("_SpecularNormalTexture", targetTexture);
        }

        Shader.SetGlobalMatrix("_LightMatrix", lightMatrix);
    }
}
