//
//  Shader.fsh
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
